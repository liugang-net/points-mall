# frozen_string_literal: true

class PointsMall::AdminScoreEventSerializer < ApplicationSerializer
  attributes :id, :user_id, :date, :points, :description, :created_at, :updated_at

  has_one :user, serializer: BasicUserSerializer, embed: :objects

  def user
    object.user
  end
end

