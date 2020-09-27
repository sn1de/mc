# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  description :string           not null
#  name        :string           not null
#  price       :decimal(10, 2)   not null
#  quantity    :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_products_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe Product, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
