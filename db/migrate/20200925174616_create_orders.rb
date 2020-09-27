class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :customer_name
      t.string :card_number
      t.string :card_exp_month
      t.string :card_exp_year
      t.string :card_cvc
      t.integer :product_id
      t.integer :quantity
    end
  end
end
