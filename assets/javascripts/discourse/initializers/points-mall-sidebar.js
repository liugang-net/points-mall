import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

export default {
    name: "points-mall-sidebar",

    initialize(container) {
        const siteSettings = container.lookup("service:site-settings");
        if (!siteSettings.points_mall_enabled) {
            return;
        }

        withPluginApi((api) => {
            // 添加积分商城链接到社区区块
            api.addCommunitySectionLink((baseSectionLink) => {
                return class PointsMallSectionLink extends baseSectionLink {
                    name = "points-mall";
                    route = "points-mall.products";
                    text = i18n("points_mall.products.title");
                    title = i18n("points_mall.products.title");
                    defaultPrefixValue = "gift";
                };
            });
        });
    },
};

