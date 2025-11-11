# frozen_string_literal: true

class CreatePointsMallProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :points_mall_products do |t|
      t.string :name, null: false
      t.text :description
      t.integer :upload_id # 商品图片
      t.integer :stock, null: false, default: 0 # 库存
      t.integer :points_required, null: false # 兑换所需积分
      t.boolean :active, null: false, default: true # 是否上架
      t.integer :sort_order, null: false, default: 0 # 排序
      t.integer :created_by_id, null: false # 创建者

      t.timestamps
    end

    add_index :points_mall_products, :active
    add_index :points_mall_products, :sort_order
    add_index :points_mall_products, :created_by_id
  end
end

