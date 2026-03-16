# frozen_string_literal: true

class PointsMall::UserPageController < ::ApplicationController
  requires_plugin PointsMall::PLUGIN_NAME

  def orders
    render "default/empty"
  end
end


