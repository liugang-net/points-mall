# frozen_string_literal: true

class PointsMall::OrderController < ::ApplicationController
  requires_plugin PointsMall::PLUGIN_NAME

  before_action :ensure_logged_in

  def create
    params.require(%i[product_id quantity])
    params.permit(:recipient_name, :recipient_phone, :recipient_address, :user_notes)

    product = PointsMall::Product.find_by(id: params[:product_id])
    raise Discourse::NotFound unless product

    quantity = params[:quantity].to_i
    raise Discourse::InvalidParameters.new(:quantity) if quantity <= 0

    requires_shipping = product.physical?

    if requires_shipping
      %i[recipient_name recipient_phone recipient_address].each do |field|
        next if params[field].present?
        raise Discourse::InvalidParameters.new(
                I18n.t("points_mall.orders.missing_recipient_info"),
              )
      end
    end

    # 检查商品是否可购买
    unless product.can_purchase?(quantity)
      raise Discourse::InvalidParameters.new(I18n.t("points_mall.orders.product_unavailable"))
    end

    # 检查用户积分是否足够（从数据库直接计算，更安全）
    user_score = PointsMall::UserScoreCalculator.current_score(user_id: current_user.id)
    required_points = product.points_required * quantity
    if user_score < required_points
      raise Discourse::InvalidParameters.new(
        I18n.t("points_mall.orders.insufficient_points", required: required_points, current: user_score),
      )
    end

    # 使用事务创建订单并扣减积分
    order = nil
    ActiveRecord::Base.transaction do
      # 同一用户的兑换串行执行，避免并发请求重复消费同一份余额。
      User.lock.find(current_user.id)

      # 锁定商品行，防止并发问题
      product = PointsMall::Product.lock.find(product.id)
      unless product.can_purchase?(quantity)
        raise Discourse::InvalidParameters.new(I18n.t("points_mall.orders.product_unavailable"))
      end

      # 在事务内再次检查用户积分（防止并发问题）
      current_user_score = PointsMall::UserScoreCalculator.current_score(user_id: current_user.id)
      if current_user_score < required_points
        raise Discourse::InvalidParameters.new(
          I18n.t("points_mall.orders.insufficient_points", required: required_points, current: current_user_score),
        )
      end

      # 创建订单
      order =
        PointsMall::Order.create!(
          user_id: current_user.id,
          product_id: product.id,
          quantity: quantity,
          points_spent: product.points_required,
          recipient_name: requires_shipping ? params[:recipient_name] : nil,
          recipient_phone: requires_shipping ? params[:recipient_phone] : nil,
          recipient_address: requires_shipping ? params[:recipient_address] : nil,
          user_notes: params[:user_notes],
          status: PointsMall::Order.statuses[:pending],
        )

      # 扣减库存
      product.decrement!(:stock, quantity)

      # 创建积分事件（扣减积分）
      event_date = Date.today
      DiscourseGamification::GamificationScoreEvent.create!(
        user_id: current_user.id,
        date: event_date,
        points: -required_points,
        description: I18n.t("points_mall.orders.purchase_description", product_name: product.name, quantity: quantity),
      )

      # 重新计算用户积分（只重新计算事件发生当天的积分，更高效）
      PointsMall::UserScoreCalculator.recalculate_user_score(user_id: current_user.id, date: event_date)
      # 异步刷新排行榜
      if defined?(Jobs::RefreshUserLeaderboards)
        Jobs.enqueue(Jobs::RefreshUserLeaderboards, user_id: current_user.id)
      end
    end

    render_serialized(order, PointsMall::OrderSerializer, root: false)
  rescue ActiveRecord::RecordInvalid => e
    render_json_error(e.record)
  end

  def my_orders
    params.permit(%i[page limit status])

    orders =
      PointsMall::Order
        .where(user_id: current_user.id)
        .includes(product: :upload)

    orders = orders.where(status: params[:status]) if params[:status].present?

    # 分页
    limit = params[:limit]&.to_i || 20
    limit = [limit, 100].min
    page = params[:page]&.to_i || 1
    offset = (page - 1) * limit

    total_count = orders.count
    orders = orders.recent.limit(limit).offset(offset)

    render_serialized(
      { orders: orders, total: total_count, page: page, limit: limit },
      PointsMall::OrderIndexSerializer,
      root: false,
    )
  end

  def show
    params.require(:id)

    order =
      PointsMall::Order
        .where(user_id: current_user.id, id: params[:id])
        .includes(product: :upload)
        .first

    raise Discourse::NotFound unless order

    render_serialized(order, PointsMall::OrderSerializer, root: false)
  end
end
