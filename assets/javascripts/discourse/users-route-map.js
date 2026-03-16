export default {
  resource: "user",
  map() {
    this.route("points-mall-orders", { path: "/points-mall/orders" });
    this.route("points-mall-order", { path: "/points-mall/orders/:order_id" });
  },
};


