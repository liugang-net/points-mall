# frozen_string_literal: true

class PointsMall::AdminScoreEventIndexSerializer < ApplicationSerializer
  attributes :total, :page, :limit

  has_many :events, serializer: PointsMall::AdminScoreEventSerializer, embed: :objects

  def events
    object[:events]
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

