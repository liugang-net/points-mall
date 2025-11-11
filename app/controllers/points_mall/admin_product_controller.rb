# frozen_string_literal: true

class PointsMall::AdminProductController < Admin::AdminController
  requires_plugin PointsMall::PLUGIN_NAME

  before_action :ensure_admin

  def index
    params.permit(%i[page limit search active])

    products = PointsMall::Product.includes(:creator, :upload)

    # 搜索条件
    if params[:search].present?
      products = products.where("name ILIKE ?", "%#{params[:search]}%")
    end

    if params[:active].present?
      products = products.where(active: params[:active] == "true")
    end

    # 分页
    limit = params[:limit]&.to_i || 20
    limit = [limit, 100].min
    page = params[:page]&.to_i || 1
    offset = (page - 1) * limit

    total_count = products.count
    products = products.ordered.limit(limit).offset(offset)

    render_serialized(
      { products: products, total: total_count, page: page, limit: limit },
      PointsMall::AdminProductIndexSerializer,
      root: false,
    )
  end

  def show
    params.permit(:id)

    product = PointsMall::Product.find_by(id: params[:id])
    raise Discourse::NotFound unless product

    render_serialized(product, PointsMall::AdminProductSerializer, root: false)
  end

  def create
    params.require(%i[name points_required stock])
    params.permit(%i[description upload_id active sort_order])

    product =
      PointsMall::Product.new(
        name: params[:name],
        description: params[:description],
        upload_id: params[:upload_id],
        stock: params[:stock],
        points_required: params[:points_required],
        active: params[:active] != false,
        sort_order: params[:sort_order] || 0,
        created_by_id: current_user.id,
      )

    if product.save
      render_serialized(product, PointsMall::AdminProductSerializer, root: false)
    else
      render_json_error(product)
    end
  end

  def update
    params.require(:id)
    params.permit(
      %i[name description upload_id stock points_required active sort_order],
    )

    product = PointsMall::Product.find_by(id: params[:id])
    raise Discourse::NotFound unless product

    product.name = params[:name] if params[:name].present?
    product.description = params[:description] if params.key?(:description)
    product.upload_id = params[:upload_id] if params.key?(:upload_id)
    product.stock = params[:stock] if params[:stock].present?
    product.points_required = params[:points_required] if params[:points_required].present?
    product.active = params[:active] if params.key?(:active)
    product.sort_order = params[:sort_order] if params[:sort_order].present?

    if product.save
      render_serialized(product, PointsMall::AdminProductSerializer, root: false)
    else
      render_json_error(product)
    end
  end

  def destroy
    params.require(:id)

    product = PointsMall::Product.find_by(id: params[:id])
    raise Discourse::NotFound unless product

    if product.orders.exists?
      render_json_error(I18n.t("points_mall.admin.products.has_orders"))
    elsif product.destroy
      render json: success_json
    else
      render_json_error(product)
    end
  end
end

