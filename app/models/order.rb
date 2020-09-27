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
end
