# frozen_string_literal: true

module PointsMall
  class Order < ::ActiveRecord::Base
    self.table_name = "points_mall_orders"

    belongs_to :user
    belongs_to :product, class_name: "PointsMall::Product"

    validates :user_id, presence: true
    validates :product_id, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :points_spent, presence: true, numericality: { greater_than: 0 }
    validates :recipient_name, presence: true
    validates :recipient_phone, presence: true
    validates :recipient_address, presence: true

    enum :status, {
      pending: 0,    # 待发货
      shipped: 1,     # 已发货
      completed: 2,  # 已完成
      cancelled: 3,  # 已取消
    }

    scope :recent, -> { order(created_at: :desc) }

    def total_points_spent
      points_spent * quantity
    end

    def can_cancel?
      pending?
    end

    def can_ship?
      pending?
    end

    def can_complete?
      shipped?
    end
  end
end

# == Schema Information
#
# Table name: points_mall_orders
#
#  id               :bigint           not null, primary key
#  user_id          :integer          not null
#  product_id       :integer          not null
#  quantity         :integer          not null, default(1)
#  points_spent     :integer          not null
#  status           :integer          not null, default(0)
#  recipient_name   :string           not null
#  recipient_phone  :string           not null
#  recipient_address:text             not null
#  admin_notes      :text
#  user_notes       :text
#  shipped_at       :datetime
#  completed_at     :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

