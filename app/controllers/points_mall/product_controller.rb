# frozen_string_literal: true

class PointsMall::ProductController < ::ApplicationController
  requires_plugin PointsMall::PLUGIN_NAME

  def index
    params.permit(%i[page limit])

    products = PointsMall::Product.active.includes(:upload)

    # 分页
    limit = params[:limit]&.to_i || 20
    limit = [limit, 100].min
    page = params[:page]&.to_i || 1
    offset = (page - 1) * limit

    total_count = products.count
    products = products.ordered.limit(limit).offset(offset)

    render_serialized(
      { products: products, total: total_count, page: page, limit: limit },
      PointsMall::ProductIndexSerializer,
      root: false,
    )
  end

  def show
    params.permit(:id)

    product = PointsMall::Product.active.find_by(id: params[:id])
    raise Discourse::NotFound unless product

    render_serialized(product, PointsMall::ProductSerializer, root: false)
  end

  def respond
    # 前端路由处理，返回 JSON 数据供 Ember.js 使用
    discourse_expires_in 1.minute

    if params[:id].present?
      # 单个商品详情
      product = PointsMall::Product.active.find_by(id: params[:id])
      raise Discourse::NotFound unless product

      render_serialized(product, PointsMall::ProductSerializer, root: false)
    else
      # 商品列表
      params.permit(%i[page limit])

      products = PointsMall::Product.active.includes(:upload)

      # 分页
      limit = params[:limit]&.to_i || 20
      limit = [limit, 100].min
      page = params[:page]&.to_i || 1
      offset = (page - 1) * limit

      total_count = products.count
      products = products.ordered.limit(limit).offset(offset)

      render_serialized(
        { products: products, total: total_count, page: page, limit: limit },
        PointsMall::ProductIndexSerializer,
        root: false,
      )
    end
  end
end

