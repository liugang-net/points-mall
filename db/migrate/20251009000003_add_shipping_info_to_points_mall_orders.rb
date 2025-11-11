# frozen_string_literal: true

class AddShippingInfoToPointsMallOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :points_mall_orders, :shipping_company, :string # 快递公司
    add_column :points_mall_orders, :shipping_number, :string # 快递单号
  end
end

