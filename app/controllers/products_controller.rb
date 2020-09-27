class ProductsController < ApplicationController
  def index
    @page = params.fetch(:page, 0)
    @per = params.fetch(:per, 10)
    @products = Product.order(:id).limit(@per).offset(@page * @per)
  end
end
