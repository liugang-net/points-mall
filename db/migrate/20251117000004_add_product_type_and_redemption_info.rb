# frozen_string_literal: true

class AddProductTypeAndRedemptionInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :points_mall_products,
               :product_type,
               :integer,
               null: false,
               default: 0 # 0 = 实物, 1 = 虚拟

    add_index :points_mall_products, :product_type

    add_column :points_mall_orders, :redemption_info, :text

    change_column_null :points_mall_orders, :recipient_name, true
    change_column_null :points_mall_orders, :recipient_phone, true
    change_column_null :points_mall_orders, :recipient_address, true
  end
end

