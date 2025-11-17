# frozen_string_literal: true

class PointsMall::ProductSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :description,
             :upload_id,
             :stock,
             :points_required,
             :product_type,
             :created_at,
             :can_purchase,
             :available

  has_one :upload, serializer: UploadSerializer, embed: :objects

  def upload
    object.upload
  end

  def can_purchase
    object.can_purchase?
  end

  def available
    object.available?
  end
end

