# frozen_string_literal: true

class PointsMall::ProductIndexSerializer < ApplicationSerializer
  attributes :total, :page, :limit

  has_many :products, serializer: PointsMall::ProductSerializer, embed: :objects

  def products
    object[:products]
  end

  def total
    object[:total]
  end

  def page
    object[:page]
  end

  def limit
    object[:limit]
  end
end

