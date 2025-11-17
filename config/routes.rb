# frozen_string_literal: true

PointsMall::Engine.routes.draw do
  # 前端路由支持（类似游戏化插件，处理所有请求返回 JSON）
  get "/" => "product#respond"
  get "/products" => "product#respond"
  get "/products/:id" => "product#respond"
  
  # API 路由
  post "/orders" => "order#create"
  get "/orders/my" => "order#my_orders"
  get "/orders/:id" => "order#show"
end

Discourse::Application.routes.draw do
  mount ::PointsMall::Engine, at: "/points-mall"

  %w[users u].each do |root_path|
    get "#{root_path}/:username/points-mall/orders" => "points_mall/user_page#orders",
        constraints: { username: RouteFormat.username }

    get "#{root_path}/:username/points-mall/orders/:order_id" => "points_mall/user_page#orders",
        constraints: {
          username: RouteFormat.username,
          order_id: /\d+/,
        }
  end

  # 管理员积分事件管理路由（仅管理员可访问）
  scope "/admin/plugins/points-mall", constraints: AdminConstraint.new do
    # API 路由（使用下划线）
    get "/score_events" => "points_mall/admin_score_event#index"
    get "/score_events/:id" => "points_mall/admin_score_event#show"
    post "/score_events" => "points_mall/admin_score_event#create"
    put "/score_events/:id" => "points_mall/admin_score_event#update"
    delete "/score_events/:id" => "points_mall/admin_score_event#destroy"
    
    # 商品管理路由
    get "/products" => "points_mall/admin_product#index"
    get "/products/:id" => "points_mall/admin_product#show"
    post "/products" => "points_mall/admin_product#create"
    put "/products/:id" => "points_mall/admin_product#update"
    delete "/products/:id" => "points_mall/admin_product#destroy"
    
    # 订单管理路由
    get "/orders" => "points_mall/admin_order#index"
    get "/orders/:id" => "points_mall/admin_order#show"
    put "/orders/:id/status" => "points_mall/admin_order#update_status"
    put "/orders/:id" => "points_mall/admin_order#update"
    
    # 前端路由支持（使用连字符，用于 Ember 路由）
    get "/score-events" => "points_mall/admin_score_event#index"
    get "/score-events/*path" => "points_mall/admin_score_event#index", constraints: { path: /.*/ }
    get "/products-page" => "points_mall/admin_product#index"
    get "/products-page/*path" => "points_mall/admin_product#index", constraints: { path: /.*/ }
    get "/orders-page" => "points_mall/admin_order#index"
    get "/orders-page/*path" => "points_mall/admin_order#index", constraints: { path: /.*/ }
  end
end
