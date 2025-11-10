# frozen_string_literal: true

PointsMall::Engine.routes.draw do
  # Empty routes for now
end

Discourse::Application.routes.draw do
  mount ::PointsMall::Engine, at: "points-mall"

  # 管理员积分事件管理路由（仅管理员可访问）
  scope "/admin/plugins/points-mall", constraints: AdminConstraint.new do
    # API 路由（使用下划线）
    get "/score_events" => "points_mall/admin_score_event#index"
    get "/score_events/:id" => "points_mall/admin_score_event#show"
    post "/score_events" => "points_mall/admin_score_event#create"
    put "/score_events/:id" => "points_mall/admin_score_event#update"
    delete "/score_events/:id" => "points_mall/admin_score_event#destroy"
    
    # 前端路由支持（使用连字符，用于 Ember 路由）
    get "/score-events" => "points_mall/admin_score_event#index"
    get "/score-events/*path" => "points_mall/admin_score_event#index", constraints: { path: /.*/ }
  end
end
