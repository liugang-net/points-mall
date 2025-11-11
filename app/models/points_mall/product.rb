# frozen_string_literal: true

module PointsMall
  class Product < ::ActiveRecord::Base
    self.table_name = "points_mall_products"

    belongs_to :creator, class_name: "User", foreign_key: "created_by_id"
    belongs_to :upload, class_name: "Upload", optional: true
    has_many :orders, class_name: "PointsMall::Order", foreign_key: "product_id", dependent: :restrict_with_error

    validates :name, presence: true
    validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :points_required, presence: true, numericality: { greater_than: 0 }
    validates :created_by_id, presence: true

    scope :active, -> { where(active: true) }
    scope :ordered, -> { order(sort_order: :asc, created_at: :desc) }

    def active?
      active == true
    end

    def available?
      active? && stock > 0
    end

    def can_purchase?(quantity = 1)
      available? && stock >= quantity
    end
  end
end

# == Schema Information
#
# Table name: points_mall_products
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  description     :text
#  upload_id       :integer
#  stock           :integer          not null, default(0)
#  points_required :integer          not null
#  active          :boolean          not null, default(true)
#  sort_order      :integer          not null, default(0)
#  created_by_id   :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

