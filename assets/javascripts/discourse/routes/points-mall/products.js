import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { number as formatNumber } from "discourse/lib/formatter";

export default class PointsMallProductsRoute extends DiscourseRoute {
    @service site;
    @service currentUser;

    async model() {
        try {
            const data = await ajax("/points-mall/products.json");
            return {
                products: data.products || [],
                total: data.total || 0,
            };
        } catch (error) {
            popupAjaxError(error);
            return { products: [], total: 0 };
        }
    }

    setupController(controller, model) {
        super.setupController(controller, model);
        // 为每个商品添加格式化后的积分和可购买状态
        const formatPoints = (value) => {
            if (value == null || isNaN(value)) return "0";
            return formatNumber(value, { maxDisplay: 1000000 });
        };
        // 只有登录用户才设置积分
        const userScore = this.currentUser?.gamification_score || 0;
        const products = (model.products || []).map(product => ({
            ...product,
            formattedPointsRequired: formatPoints(product.points_required),
        }));
        controller.products = products;
        controller.userScore = userScore;
    }
}

