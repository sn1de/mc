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
class Order < ApplicationRecord
  # TODO: Implement me! (part 1)
  belongs_to :product

  validates :card_number, length: { is: 16 }
  validates :card_number, numericality: { only_integer: true }
  validates :card_exp_month, numericality: { 
  	only_integer: true,
  	greater_than_or_equal_to: 1,
  	less_than_or_equal_to: 12
  }
  validates :card_exp_year, numericality: { only_integer: true }
  validates :card_cvc, length: { is: 3 }
  validates :card_cvc, numericality: { only_integer: true }
  validates :quantity, numericality: { 
  	only_integer: true,
  	greater_than_or_equal_to: 1
  }
  validates :product_id, numericality: { only_integer: true }
end
