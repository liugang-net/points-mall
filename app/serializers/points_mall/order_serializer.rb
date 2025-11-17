# frozen_string_literal: true

class PointsMall::OrderSerializer < ApplicationSerializer
  attributes :id,
             :product_id,
             :quantity,
             :points_spent,
             :total_points_spent,
             :status,
             :shipping_company,
             :shipping_number,
             :redemption_info,
             :product_type,
             :product_name,
             :product_description,
             :recipient_name,
             :recipient_phone,
             :recipient_address,
             :admin_notes,
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
    return 0 unless defined?(DiscourseGamification::GamificationScore)

    @user_score_cache ||= {}
    @user_score_cache[object.user_id] ||= begin
      DiscourseGamification::GamificationScore.where(user_id: object.user_id).sum(:score) || 0
    end
  end

  def product_type
    object.product&.product_type || "physical"
  end

  def product_name
    object.product&.name
  end

  def product_description
    object.product&.description
  end
end

