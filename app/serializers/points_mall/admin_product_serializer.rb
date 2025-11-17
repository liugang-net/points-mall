# frozen_string_literal: true

class PointsMall::AdminProductSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :description,
             :upload_id,
             :stock,
             :points_required,
             :product_type,
             :active,
             :sort_order,
             :created_by_id,
             :created_at,
             :updated_at

  has_one :upload, serializer: UploadSerializer, embed: :objects
  has_one :creator, serializer: BasicUserSerializer, embed: :objects

  def upload
    object.upload
  end

  def creator
    object.creator
  end
end

