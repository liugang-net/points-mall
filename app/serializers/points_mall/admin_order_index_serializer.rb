# frozen_string_literal: true

class PointsMall::AdminOrderIndexSerializer < ApplicationSerializer
  attributes :total, :page, :limit

  has_many :orders, serializer: PointsMall::AdminOrderSerializer, embed: :objects

  def orders
    object[:orders]
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

