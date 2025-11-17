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
    validates :recipient_name, presence: true, if: :requires_shipping_info?
    validates :recipient_phone, presence: true, if: :requires_shipping_info?
    validates :recipient_address, presence: true, if: :requires_shipping_info?
    validate :redemption_info_presence_for_virtual_shipments

    delegate :product_type, :physical?, :virtual?, to: :product, prefix: true, allow_nil: true

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

    def virtual_product?
      product&.virtual?
    end

    def requires_shipping_info?
      !virtual_product?
    end

    def requires_redemption_info?
      virtual_product? && (shipped? || completed?)
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

    private

    def redemption_info_presence_for_virtual_shipments
      return unless requires_redemption_info?
      errors.add(:redemption_info, :blank) if redemption_info.blank?
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

