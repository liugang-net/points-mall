import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PointsMallProductsRoute extends DiscourseRoute {
    @service adminPluginNavManager;

    async model(params) {
        const controller = this.controllerFor("admin-plugins.show.points-mall-products");
        if (controller) {
            controller.loading = true;
        }

        if (!this.currentUser?.admin) {
            if (controller) {
                controller.loading = false;
            }
            return { products: [], total: 0, page: 1, limit: 20 };
        }

        try {
            const queryParams = new URLSearchParams();
            if (params.search) queryParams.append("search", params.search);
            if (params.active !== undefined) queryParams.append("active", params.active);
            queryParams.append("page", params.page || 1);
            queryParams.append("limit", params.limit || 20);

            const queryString = queryParams.toString();
            const url = `/admin/plugins/points-mall/products?${queryString}`;

            const data = await ajax(url);
            const result = {
                products: data.products || [],
                total: data.total || 0,
                page: data.page || 1,
                limit: data.limit || 20,
            };
            return result;
        } catch (error) {
            popupAjaxError(error);
            return { products: [], total: 0, page: 1, limit: 20 };
        } finally {
            if (controller) {
                controller.loading = false;
            }
        }
    }

    titleToken() {
        return i18n("points_mall.admin.products.title");
    }

    setupController(controller, model) {
        super.setupController(controller, model);
        if (model) {
            controller.products = [...(model.products || [])];
            controller.total = model.total || 0;
            controller.currentPage = model.page || 1;
            if (model.limit) {
                controller.limit = model.limit;
            }
        }
        controller.loading = false;
    }
}

