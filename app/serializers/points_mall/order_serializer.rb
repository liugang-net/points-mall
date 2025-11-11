# frozen_string_literal: true

class PointsMall::OrderSerializer < ApplicationSerializer
  attributes :id,
             :product_id,
             :quantity,
             :points_spent,
             :total_points_spent,
             :status,
             :recipient_name,
             :recipient_phone,
             :recipient_address,
             :user_notes,
             :shipped_at,
             :completed_at,
             :user_current_score,
             :created_at,
             :updated_at

  has_one :product, serializer: PointsMall::ProductSerializer, embed: :objects

  def product
    object.product
  end

  def total_points_spent
    object.total_points_spent
  end

  # 返回用户当前积分（兑换后的最新积分）
  def user_current_score
    if defined?(DiscourseGamification::GamificationScore)
      DiscourseGamification::GamificationScore.where(user_id: object.user_id).sum(:score) || 0
    else
      0
    end
  end
end

