class OrderConfirmationService

  # The code below, as far as I can tell, ought to be sufficient for
  # most databases, but I believe it is still vulnerable on sqlite.
  # Sqlite's default transaction isolation level is serializable, which
  # would seem to make something like this relatively straightforward, but
  # it lacks a SELECT FOR UPDATE capability, making it difficult to
  # aquire a read lock against the product table. Essentially, sqlite will
  # not grant the read lock until an update or other write statement occurs,
  # leaving a window between the initial read and update of the product quantity
  # where a competing transaction could write an update that would cause the
  # original commit to fail with a SQLITE_BUSY error. This condition is not
  # catastrophic, in that the data integrity is intact, only one transaction
  # having been commited and the other discarded. The issue becomse how
  # do you deal with it gracefully? One solution would be to patch or otherwise
  # overrite the transaction creation to set the transaction to BEGIN IMMEDIATE
  # which will acquire both the read and write locks at the inception of the
  # transaction. This has the downside of impacting scalability and also
  # being a very database specific solution and out of step with the
  # ActiveRecord transaction capabilities. Since there was some guidance 
  # to stick to Rails/ActiveRecord transaction handling capabilities, I went
  # with the approach below, to call for a lock on the initial read to get
  # the product quantity. On postgresql or mysql, this should generate
  # a SELECT FOR UPDATE statement that will block any other processes from
  # reading the product quantity before it can be validated, decremented and
  # the corresponting order committed to the database. I haven't verified this
  # behavior first hand, but will try and swap out the database to see if it
  # holds up.

  def perform(product_id:, quantity:, customer_name:, card_number:, card_exp_month:, card_exp_year:, card_cvc:)
    order = Order.new(
      quantity: quantity,
      customer_name: customer_name,
      card_number: card_number,
      card_exp_month: card_exp_month,
      card_exp_year: card_exp_year,
      card_cvc: card_cvc)

    begin
      Product.transaction do
        # attempt to reserve inventory from product quantity available
        product = Product.lock(true).find(product_id)
        product.reserve_inventory!(quantity)
        order.product = product
        order.save!
	    end
    rescue ActiveRecord::RecordInvalid => invalid
      invalid.record.errors.each { |e| puts "Errors from order creation attempt: #{e}" }
      order = nil
   end

   order
 end
end
