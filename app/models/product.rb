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
class Product < ApplicationRecord
  has_one_attached :photo
  has_many :orders

  validates :name, presence: true
  validates :description, presence: true
  validates :photo, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than: 0 }

  # use to determine if sufficient inventory is available to be
  # reserved in preparation for order generation
  def reserve_inventory!(order_quantity)
    self.quantity -= order_quantity
    save!
  end
end
