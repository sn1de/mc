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
