# frozen_string_literal: true

class PointsMall::AdminOrderController < Admin::AdminController
  requires_plugin PointsMall::PLUGIN_NAME

  before_action :ensure_admin

  def index
    params.permit(%i[page limit user_id username status start_date end_date])

    orders = PointsMall::Order.includes(:user, :product)

    # 查询条件
    orders = orders.where(user_id: params[:user_id]) if params[:user_id].present?
    if params[:username].present?
      orders = orders.joins(:user).where("users.username = ?", params[:username])
    end
    orders = orders.where(status: params[:status]) if params[:status].present?
    orders = orders.where("created_at >= ?", params[:start_date]) if params[:start_date].present?
    orders = orders.where("created_at <= ?", params[:end_date]) if params[:end_date].present?

    # 分页
    limit = params[:limit]&.to_i || 20
    limit = [limit, 100].min
    page = params[:page]&.to_i || 1
    offset = (page - 1) * limit

    total_count = orders.count
    orders = orders.recent.limit(limit).offset(offset)

    render_serialized(
      { orders: orders, total: total_count, page: page, limit: limit },
      PointsMall::AdminOrderIndexSerializer,
      root: false,
    )
  end

  def show
    params.permit(:id)

    order = PointsMall::Order.find_by(id: params[:id])
    raise Discourse::NotFound unless order

    render_serialized(order, PointsMall::AdminOrderSerializer, root: false)
  end

  def update_status
    params.require(%i[id status])
    params.permit(:shipping_company, :shipping_number, :redemption_info)

    order = PointsMall::Order.find_by(id: params[:id])
    raise Discourse::NotFound unless order

    new_status = params[:status].to_i
    unless PointsMall::Order.statuses.value?(new_status)
      raise Discourse::InvalidParameters.new(:status)
    end

    case new_status
    when PointsMall::Order.statuses[:shipped]
      unless order.can_ship?
        raise Discourse::InvalidParameters.new(I18n.t("points_mall.admin.orders.cannot_ship"))
      end
      order.shipped_at = Time.current

      if order.virtual_product?
        redemption_info = params[:redemption_info].presence
        if redemption_info.blank?
          raise Discourse::InvalidParameters.new(
                  I18n.t("points_mall.admin.orders.redemption_info_required"),
                )
        end
        order.redemption_info = redemption_info
        order.shipping_company = nil
        order.shipping_number = nil
      else
        if params[:shipping_company].blank? || params[:shipping_number].blank?
          raise Discourse::InvalidParameters.new(
                  I18n.t("points_mall.admin.orders.shipping_info_required"),
                )
        end
        order.shipping_company = params[:shipping_company]
        order.shipping_number = params[:shipping_number]
      end
    when PointsMall::Order.statuses[:completed]
      unless order.can_complete?
        raise Discourse::InvalidParameters.new(I18n.t("points_mall.admin.orders.cannot_complete"))
      end
      order.completed_at = Time.current
    when PointsMall::Order.statuses[:cancelled]
      unless order.can_cancel?
        raise Discourse::InvalidParameters.new(I18n.t("points_mall.admin.orders.cannot_cancel"))
      end
      # 取消订单时，返还积分
      if defined?(DiscourseGamification::GamificationScoreEvent)
        event_date = Date.today
        DiscourseGamification::GamificationScoreEvent.create!(
          user_id: order.user_id,
          date: event_date,
          points: order.total_points_spent,
          description: I18n.t("points_mall.admin.orders.refund_description", product_name: order.product.name),
        )
        PointsMall::UserScoreCalculator.recalculate_user_score(user_id: order.user_id, date: event_date)
        if defined?(Jobs::RefreshUserLeaderboards)
          Jobs.enqueue(Jobs::RefreshUserLeaderboards, user_id: order.user_id)
        end
      end
      # 返还库存
      order.product.increment!(:stock, order.quantity)
    end

    order.status = new_status
    order.admin_notes = params[:admin_notes] if params[:admin_notes].present?

    if order.save
      render_serialized(order, PointsMall::AdminOrderSerializer, root: false)
    else
      render_json_error(order)
    end
  end

  def update
    params.require(:id)
    params.permit(:admin_notes, :shipping_company, :shipping_number, :redemption_info)

    order = PointsMall::Order.find_by(id: params[:id])
    raise Discourse::NotFound unless order

    order.admin_notes = params[:admin_notes] if params[:admin_notes].present?
    order.shipping_company = params[:shipping_company] if params[:shipping_company].present?
    order.shipping_number = params[:shipping_number] if params[:shipping_number].present?
    order.redemption_info = params[:redemption_info] if params.key?(:redemption_info)

    if order.save
      render_serialized(order, PointsMall::AdminOrderSerializer, root: false)
    else
      render_json_error(order)
    end
  end
end

