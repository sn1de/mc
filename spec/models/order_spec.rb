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
  pending "add some examples to (or delete) #{__FILE__}"
end
