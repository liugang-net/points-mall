export default {
    resource: "admin.adminPlugins.show",

    path: "/plugins",

    map() {
        this.route("points-mall-score-events", { path: "score-events" });
        this.route("points-mall-products", { path: "products-page" });
        this.route("points-mall-orders", { path: "orders-page" });
    },
};

