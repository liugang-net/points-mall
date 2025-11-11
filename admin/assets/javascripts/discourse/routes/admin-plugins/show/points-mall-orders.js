import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PointsMallOrdersRoute extends DiscourseRoute {
    @service adminPluginNavManager;

    async model(params) {
        const controller = this.controllerFor("admin-plugins.show.points-mall-orders");
        if (controller) {
            controller.loading = true;
        }

        if (!this.currentUser?.admin) {
            if (controller) {
                controller.loading = false;
            }
            return { orders: [], total: 0, page: 1, limit: 20 };
        }

        try {
            const queryParams = new URLSearchParams();
            if (params.user_id) queryParams.append("user_id", params.user_id);
            if (params.username) queryParams.append("username", params.username);
            if (params.status !== undefined) queryParams.append("status", params.status);
            if (params.start_date) queryParams.append("start_date", params.start_date);
            if (params.end_date) queryParams.append("end_date", params.end_date);
            queryParams.append("page", params.page || 1);
            queryParams.append("limit", params.limit || 20);

            const queryString = queryParams.toString();
            const url = `/admin/plugins/points-mall/orders?${queryString}`;

            const data = await ajax(url);
            const result = {
                orders: data.orders || [],
                total: data.total || 0,
                page: data.page || 1,
                limit: data.limit || 20,
            };
            return result;
        } catch (error) {
            popupAjaxError(error);
            return { orders: [], total: 0, page: 1, limit: 20 };
        } finally {
            if (controller) {
                controller.loading = false;
            }
        }
    }

    titleToken() {
        return i18n("points_mall.admin.orders.title");
    }

    setupController(controller, model) {
        super.setupController(controller, model);
        if (model) {
            // 为每个订单添加格式化后的状态文本和状态码
            const statusMap = {
                "pending": 0,
                "shipped": 1,
                "completed": 2,
                "cancelled": 3,
            };
            const ordersWithStatusText = (model.orders || []).map(order => ({
                ...order,
                statusText: controller.getStatusText(statusMap[order.status] ?? order.status),
                statusCode: statusMap[order.status] ?? order.status, // 添加状态码用于模板比较
            }));
            controller.orders = [...ordersWithStatusText];
            controller.total = model.total || 0;
            controller.currentPage = model.page || 1;
            if (model.limit) {
                controller.limit = model.limit;
            }
        }
        controller.loading = false;
    }
}

