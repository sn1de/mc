class OrdersController < ApplicationController
  before_action :set_order, only: [:show] # add create next

  def new
    @order = Order.new
    @order.product = Product.find(params[:product_id])
  end

  def create
  	@order = Order.new(order_params)

    if @order.valid?
      conf = OrderConfirmationService.new

      op = order_params
      # If there is a shortcut way to not have to type out all of these
      # parameters, I would love to know about it. Any form of hash I
      # tried to put in kicked back an error about the required parameters.
      # I tried to do op.to_h but it didn't like that at all.
      @confirmed_order = conf.perform(
        product_id: op[:product_id],
        quantity: op[:quantity].to_i,
        customer_name: op[:customer_name],
        card_number: op[:card_number],
        card_exp_month: op[:card_exp_month],
        card_exp_year: op[:card_exp_year],
        card_cvc: op[:card_cvc])

      if @confirmed_order
        redirect_to @confirmed_order, notice: "Order was created successfully"
      else
        # we have failed to create the order due to insufficient inventory
        flash.now[:notice] = "Insufficient inventory."
        render :new
      end
    else
      # errors on the form, send them back to correct
      render :new
    end
  end

  def show
  end

  private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(
        :customer_name,
        :card_number,
        :card_exp_month,
        :card_exp_year,
        :card_cvc,
        :product_id,
        :quantity)
    end
end
