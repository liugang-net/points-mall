# frozen_string_literal: true

# name: points-mall
# about: 积分商城插件 - 管理积分事件和积分商城功能
# meta_topic_id: TODO
# version: 0.2.3
# authors: Ibomy
# url: TODO
# required_version: 2.7.0

enabled_site_setting :points_mall_enabled

module ::PointsMall
  PLUGIN_NAME = "points-mall"
end

require_relative "lib/points_mall/engine"
require_relative "lib/points_mall/user_score_calculator"

after_initialize do
  require_relative "jobs/regular/refresh_user_leaderboards"
  # 注册管理员路由
  add_admin_route(
    "points_mall.admin.title",
    "points-mall",
    { use_new_show_route: true },
  )
end

