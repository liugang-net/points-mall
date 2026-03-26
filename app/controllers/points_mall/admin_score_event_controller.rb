# frozen_string_literal: true

class PointsMall::AdminScoreEventController < Admin::AdminController
  requires_plugin PointsMall::PLUGIN_NAME

  before_action :ensure_admin

  def index
    params.permit(%i[user_id username date start_date end_date page limit])

    events = DiscourseGamification::GamificationScoreEvent.includes(:user)

    # 查询条件
    events = events.where(user_id: params[:user_id]) if params[:user_id].present?
    events = events.joins(:user).where("users.username = ?", params[:username]) if params[
      :username
    ].present?
    events = events.where(date: params[:date]) if params[:date].present?
    events = events.where("date >= ?", params[:start_date]) if params[:start_date].present?
    events = events.where("date <= ?", params[:end_date]) if params[:end_date].present?

    # 分页
    limit = params[:limit]&.to_i || 10 # 默认每页10条
    limit = [limit, 100].min # 最多100条
    page = params[:page]&.to_i || 1
    offset = (page - 1) * limit

    total_count = events.count
    events = events.order(created_at: :desc).limit(limit).offset(offset)

    render_serialized(
      { events: events, total: total_count, page: page, limit: limit },
      PointsMall::AdminScoreEventIndexSerializer,
      root: false,
    )
  end

  def show
    params.permit(:id)

    event = DiscourseGamification::GamificationScoreEvent.find_by(id: params[:id])
    raise Discourse::NotFound unless event

    render_serialized(event, PointsMall::AdminScoreEventSerializer, root: false)
  end

  def create
    params.require(%i[date points])
    params.permit(%i[user_id username description])

    user = nil
    if params[:user_id].present?
      user = User.find_by(id: params[:user_id])
    elsif params[:username].present?
      user = User.find_by(username: params[:username])
    end

    unless user
      raise Discourse::InvalidParameters.new(
              I18n.t("points_mall.admin.score_events.user_not_found"),
            )
    end

    event =
      DiscourseGamification::GamificationScoreEvent.new(
        user_id: user.id,
        date: params[:date],
        points: params[:points],
        description:
          params[:description] || I18n.t("points_mall.admin.score_events.manual_adjustment"),
      )

    if event.save
      # 同步重新计算该用户的积分（只重新计算事件发生当天的积分，更高效）
      PointsMall::UserScoreCalculator.recalculate_user_score(user_id: user.id, date: event.date)
      # 异步刷新 leaderboard positions
      if defined?(Jobs::RefreshUserLeaderboards)
        Jobs.enqueue(Jobs::RefreshUserLeaderboards, user_id: user.id)
      end
      render_serialized(event, PointsMall::AdminScoreEventSerializer, root: false)
    else
      render_json_error(event)
    end
  end

  def update
    params.require(:id)
    params.permit(%i[points description])

    event = DiscourseGamification::GamificationScoreEvent.find_by(id: params[:id])
    raise Discourse::NotFound unless event

    old_points = event.points
    event.points = params[:points] if params[:points].present?
    event.description = params[:description] if params[:description].present?

    if event.save
      # 如果积分发生变化，同步重新计算该用户的积分（只重新计算事件发生当天的积分，更高效）
      if old_points != event.points
        PointsMall::UserScoreCalculator.recalculate_user_score(
          user_id: event.user_id,
          date: event.date,
        )
        # 异步刷新 leaderboard positions
        if defined?(Jobs::RefreshUserLeaderboards)
          Jobs.enqueue(Jobs::RefreshUserLeaderboards, user_id: event.user_id)
        end
      end
      render_serialized(event, PointsMall::AdminScoreEventSerializer, root: false)
    else
      render_json_error(event)
    end
  end

  def destroy
    params.require(:id)

    event = DiscourseGamification::GamificationScoreEvent.find_by(id: params[:id])
    raise Discourse::NotFound unless event

    user_id = event.user_id
    event_date = event.date
    if event.destroy
      # 同步重新计算该用户的积分（只重新计算事件发生当天的积分，更高效）
      PointsMall::UserScoreCalculator.recalculate_user_score(user_id: user_id, date: event_date)
      # 异步刷新 leaderboard positions
      if defined?(Jobs::RefreshUserLeaderboards)
        Jobs.enqueue(Jobs::RefreshUserLeaderboards, user_id: user_id)
      end
      render json: success_json
    else
      render_json_error(event)
    end
  end
end
