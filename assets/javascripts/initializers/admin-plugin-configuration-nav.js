import { withPluginApi } from "discourse/lib/plugin-api";

export default {
    name: "points-mall-admin-plugin-configuration-nav",

    initialize(container) {
        const currentUser = container.lookup("service:current-user");
        if (!currentUser || !currentUser.admin) {
            return;
        }

        withPluginApi((api) => {
            api.addAdminPluginConfigurationNav("points-mall", [
                {
                    label: "points_mall.admin.score_events.title",
                    route: "adminPlugins.show.points-mall-score-events",
                },
                {
                    label: "points_mall.admin.products.title",
                    route: "adminPlugins.show.points-mall-products",
                },
                {
                    label: "points_mall.admin.orders.title",
                    route: "adminPlugins.show.points-mall-orders",
                },
            ]);
        });
    },
};

