-- 创建商品表
CREATE TABLE IF NOT EXISTS points_mall_products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT,
  upload_id INTEGER,
  stock INTEGER NOT NULL DEFAULT 0,
  points_required INTEGER NOT NULL,
  active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_by_id INTEGER NOT NULL,
  created_at TIMESTAMP(6) NOT NULL,
  updated_at TIMESTAMP(6) NOT NULL
);

-- 创建商品表索引
CREATE INDEX IF NOT EXISTS index_points_mall_products_on_active ON points_mall_products(active);
CREATE INDEX IF NOT EXISTS index_points_mall_products_on_sort_order ON points_mall_products(sort_order);
CREATE INDEX IF NOT EXISTS index_points_mall_products_on_created_by_id ON points_mall_products(created_by_id);

-- 创建订单表
CREATE TABLE IF NOT EXISTS points_mall_orders (
  id BIGSERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  points_spent INTEGER NOT NULL,
  status INTEGER NOT NULL DEFAULT 0,
  recipient_name VARCHAR NOT NULL,
  recipient_phone VARCHAR NOT NULL,
  recipient_address TEXT NOT NULL,
  admin_notes TEXT,
  user_notes TEXT,
  shipped_at TIMESTAMP,
  completed_at TIMESTAMP,
  created_at TIMESTAMP(6) NOT NULL,
  updated_at TIMESTAMP(6) NOT NULL
);

-- 创建订单表索引
CREATE INDEX IF NOT EXISTS index_points_mall_orders_on_user_id ON points_mall_orders(user_id);
CREATE INDEX IF NOT EXISTS index_points_mall_orders_on_product_id ON points_mall_orders(product_id);
CREATE INDEX IF NOT EXISTS index_points_mall_orders_on_status ON points_mall_orders(status);
CREATE INDEX IF NOT EXISTS index_points_mall_orders_on_created_at ON points_mall_orders(created_at);

-- 更新 schema_migrations 表，标记迁移已完成
INSERT INTO schema_migrations (version) VALUES ('20251009000001'), ('20251009000002') ON CONFLICT DO NOTHING;

