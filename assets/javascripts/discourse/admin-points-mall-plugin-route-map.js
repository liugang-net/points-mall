export default {
    resource: "admin.adminPlugins.show",

    path: "/plugins",

    map() {
        this.route("points-mall-score-events", { path: "score-events" }, function () {
            // index 路由是默认的，不需要显式定义
        });
    },
};

