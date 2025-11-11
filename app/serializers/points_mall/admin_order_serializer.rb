# frozen_string_literal: true

class PointsMall::AdminOrderSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :product_id,
             :quantity,
             :points_spent,
             :total_points_spent,
             :status,
             :recipient_name,
             :recipient_phone,
             :recipient_address,
             :admin_notes,
             :user_notes,
             :shipped_at,
             :completed_at,
             :shipping_company,
             :shipping_number,
             :created_at,
             :updated_at

  has_one :user, serializer: BasicUserSerializer, embed: :objects
  has_one :product, serializer: PointsMall::AdminProductSerializer, embed: :objects

  def user
    object.user
  end

  def product
    object.product
  end

  def total_points_spent
    object.total_points_spent
  end
end

