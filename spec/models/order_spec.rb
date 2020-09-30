# == Schema Information
#
# Table name: orders
#
#  id             :integer          not null, primary key
#  card_cvc       :string
#  card_exp_month :string
#  card_exp_year  :string
#  card_number    :string
#  customer_name  :string
#  quantity       :integer
#  product_id     :integer
#
require 'rails_helper'

RSpec.describe Order, type: :model do

  it "should decrement product quantity when an order is placed" do
    prod = Product.find_by!(name: 'Elk Ridge Survival Axe')
    original_quantity = prod.quantity
    order_quantity = 2
    order = Order.new(
      customer_name: "Tom Tester",
      card_number: "1111222233334444",
      card_exp_month: "12",
      card_exp_year: "22",
      card_cvc: "321",
      quantity: order_quantity,
      product: prod)

    conf_svc = OrderConfirmationService.new

    confirmed_order = conf_svc.perform(
        product_id: order.product_id,
        quantity: order.quantity,
        customer_name: order.customer_name,
        card_number: order.card_number,
        card_exp_month: order.card_exp_month,
        card_exp_year: order.card_exp_year,
        card_cvc: order.card_cvc)

    prod.reload
    expect(confirmed_order).not_to be nil
    expect(prod.quantity).to equal(original_quantity - order_quantity)
  end

  it "should not decrement product quantity if the order fails to save" do
    prod = Product.find_by!(name: 'Coffee Percolator Crate')
    original_quantity = prod.quantity
    order_quantity = 2

    # create an order that will not save due to the cc number being too long
    order = Order.new(
      customer_name: "Tom Failure",
      card_number: "1111222233334444x",
      card_exp_month: "12",
      card_exp_year: "22",
      card_cvc: "321",
      quantity: order_quantity,
      product: prod)

    conf_svc = OrderConfirmationService.new

    confirmed_order = conf_svc.perform(
        product_id: order.product_id,
        quantity: order.quantity,
        customer_name: order.customer_name,
        card_number: order.card_number,
        card_exp_month: order.card_exp_month,
        card_exp_year: order.card_exp_year,
        card_cvc: order.card_cvc)

    prod.reload
    expect(confirmed_order).to be nil
    expect(prod.quantity).to equal(original_quantity)
  end

  it "should not be vulnerable to sqlite busy transaction failure" do
    puts "Starting transaction concurrency test."
    begin
      expect(ActiveRecord::Base.connection.pool.size).to be > 2
      transaction_paths = []

      # This is the first transaction, it will be the first to open
      # a transaction, but will then delay the start of sql 
      # processing to allow the second transaction to perform
      # to completion.
      transaction_paths[0] = Thread.new do
        Product.transaction do
          puts "Starting first transaction path ..."
          sleep(10)
          puts "Executing product lock on first thread"
          p1 = Product.lock(true).find_by!(name: 'Exotic Meats Crate')
          puts "First thread product quantity #{ p1.quantity }"
          puts "Reserving inventory on first thread"
          p1.reserve_inventory!(2)
          p1.reload
          puts "New product quantity on first thread #{ p1.quantity }"
        end
      end

      # This is the second transaction thread. We will delay
      # the creation of the transaction to insure that the 
      # first thread has an open transaction in progress, then 
      # it will immediately proceed with the transaction activity
      # which should negate the first thread's transaction.
      transaction_paths[1] = Thread.new do
        sleep(2)
        puts "Starting second transaction path ..."
        Product.transaction do
          puts "Executing product lock on second thread"
          p2 = Product.lock(true).find_by!(name: 'Exotic Meats Crate')
          puts "Second thread product quantity #{ p2.quantity }"
          puts "Reserving inventory on second thread"
          p2.reserve_inventory!(3)
          p2.reload
          puts "New product quantity on second thread #{ p2.quantity }"
        end
      end

      transaction_paths.each(&:join)
      puts "Transaction path threads are complete."
    ensure
      ActiveRecord::Base.connection_pool.disconnect!
    end
  end

  # TODO: many of these could probably be replaced by simpler versions 
  # by using shoulda-matcher
  
  it "is not valid without a 16 digit credit card number" do
  	order = Order.new
    order.card_number = "1111222233334444"
    order.valid?
    expect(order.errors[:card_number]).to be_empty

    order.card_number = ""
    order.valid?
    expect(order.errors[:card_number]).to_not be_empty

    order.card_number = "1"
    order.valid?
    expect(order.errors[:card_number]).to_not be_empty

    order.card_number = "11112222333344449"
    order.valid?
    expect(order.errors[:card_number]).to_not be_empty

    order.card_number = "1111yyyy333344449"
    order.valid?
    expect(order.errors[:card_number]).to_not be_empty
  end

  it "is not valid without a legitimate expiration month" do
    order = Order.new
    order.card_exp_month = "1"
    order.valid?
    expect(order.errors[:card_exp_month]).to be_empty

    order.card_exp_month = "12"
    order.valid?
    expect(order.errors[:card_exp_month]).to be_empty

    order.card_exp_month = "99"
    order.valid?
    expect(order.errors[:card_exp_month]).to_not be_empty

    order.card_exp_month = "y"
    order.valid?
    expect(order.errors[:card_exp_month]).to_not be_empty
  end

  it "is not valid without a legitimate expiration year" do
    order = Order.new
    order.card_exp_year = "20"
    order.valid?
    expect(order.errors[:card_exp_year]).to be_empty

    order.card_exp_year = "20y"
    order.valid?
    expect(order.errors[:card_exp_year]).to_not be_empty

    order.card_exp_year = ""
    order.valid?
    expect(order.errors[:card_exp_year]).to_not be_empty
  end

  it "is not valid without a 3 digit CVC" do
    order = Order.new
    order.card_cvc = "123"
    order.valid?
    expect(order.errors[:card_cvc]).to be_empty

    order.card_cvc = "1"
    order.valid?
    expect(order.errors[:card_cvc]).to_not be_empty

    order.card_cvc = "1y3"
    order.valid?
    expect(order.errors[:card_cvc]).to_not be_empty

    order.card_cvc = "1234"
    order.valid?
    expect(order.errors[:card_cvc]).to_not be_empty

    order.card_cvc = "12"
    order.valid?
    expect(order.errors[:card_cvc]).to_not be_empty
  end

  it "is not valid without a quantity" do
    order = Order.new
    order.valid?
    expect(order.errors[:quantity]).to_not be_empty
 
    order.quantity = 1
    order.valid?
    expect(order.errors[:quantity]).to be_empty

    order.quantity = 0
    order.valid?
    expect(order.errors[:quantity]).to_not be_empty
 
    order.quantity = -2
    order.valid?
    expect(order.errors[:quantity]).to_not be_empty

    order.quantity = 1.5
    order.valid?
    expect(order.errors[:quantity]).to_not be_empty

    order.quantity = "five"
    order.valid?
    expect(order.errors[:quantity]).to_not be_empty
  end

  it "is not valid without a product_id" do
    order = Order.new
    order.valid?
    expect(order.errors[:product_id]).to_not be_empty

    order.product_id = 1
    order.valid?
    expect(order.errors[:product_id]).to be_empty

    order.product_id = 1.5
    order.valid?
    expect(order.errors[:product_id]).to_not be_empty

    order.product_id = "y"
    order.valid?
    expect(order.errors[:product_id]).to_not be_empty
  end
end
