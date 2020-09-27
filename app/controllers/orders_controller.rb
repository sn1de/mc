class OrdersController < ApplicationController
  before_action :set_order, only: [:show] # add create next
  def new
    @order = Order.new
    @order.product = Product.find(params[:product_id])
  end

  def create
  	@order = Order.new(order_params)
    # conf = OrderConfirmationService.new
    # success = conf.perform(
    #   product_id: order_params[:product_id], 
    #   quantity: order_params[:quantity], 
    #   customer_name: order_params[:customer_name], 
    #   card_number: order_params[:card_number], 
    #   card_exp_month: order_params[:card_exp_month], 
    #   card_exp_year: order_params[:card_exp_year], 
    #   card_cvc: order_params[:card_cvc])

    if @order.save
      redirect_to @order, notice: "Order was created successfully"
    else
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
