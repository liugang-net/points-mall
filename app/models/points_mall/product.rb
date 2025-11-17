# frozen_string_literal: true

module PointsMall
  class Product < ::ActiveRecord::Base
    self.table_name = "points_mall_products"

    belongs_to :creator, class_name: "User", foreign_key: "created_by_id"
    belongs_to :upload, class_name: "Upload", optional: true
    has_many :orders,
             class_name: "PointsMall::Order",
             foreign_key: "product_id",
             dependent: :restrict_with_error

    validates :name, presence: true
    validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :points_required, presence: true, numericality: { greater_than: 0 }
    validates :created_by_id, presence: true
    validates :product_type, presence: true

    enum :product_type, { physical: 0, virtual: 1 }

    scope :active, -> { where(active: true) }
    scope :ordered, -> { order(sort_order: :asc, created_at: :desc) }

    after_commit :sync_upload_reference!, on: %i[create update]
    after_commit :remove_upload_references!, on: :destroy

    def active?
      active == true
    end

    def available?
      active? && stock > 0
    end

    def can_purchase?(quantity = 1)
      available? && stock >= quantity
    end

    private

    def sync_upload_reference!
      ::UploadReference.ensure_exist!(target: self, upload_ids: [upload_id]) if upload_id.present?

      upload_change = previous_changes["upload_id"]
      return if upload_change.blank?

      old_upload_id = upload_change[0]
      return if old_upload_id.blank? || old_upload_id == upload_id

      ::UploadReference.where(target: self, upload_id: old_upload_id).delete_all
    end

    def remove_upload_references!
      ::UploadReference.where(target: self).delete_all
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
