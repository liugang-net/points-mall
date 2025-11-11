# frozen_string_literal: true

class CreatePointsMallOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :points_mall_orders do |t|
      t.integer :user_id, null: false # 用户ID
      t.integer :product_id, null: false # 商品ID
      t.integer :quantity, null: false, default: 1 # 数量
      t.integer :points_spent, null: false # 消耗的积分
      t.integer :status, null: false, default: 0 # 订单状态：0=待发货, 1=已发货, 2=已完成, 3=已取消
      
      # 收件信息
      t.string :recipient_name, null: false # 收件人姓名
      t.string :recipient_phone, null: false # 收件人电话
      t.text :recipient_address, null: false # 收件地址
      
      t.text :admin_notes # 管理员备注
      t.text :user_notes # 用户备注
      t.datetime :shipped_at # 发货时间
      t.datetime :completed_at # 完成时间

      t.timestamps
    end

    add_index :points_mall_orders, :user_id
    add_index :points_mall_orders, :product_id
    add_index :points_mall_orders, :status
    add_index :points_mall_orders, :created_at
  end
end

