import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PointsMallScoreEventsRoute extends DiscourseRoute {
    @service adminPluginNavManager;

    async model(params) {
        if (!this.currentUser?.admin) {
            return { events: [], total: 0, page: 1, limit: 10 };
        }

        try {
            const queryParams = new URLSearchParams();
            if (params.user_id) queryParams.append("user_id", params.user_id);
            if (params.username) queryParams.append("username", params.username);
            if (params.date) queryParams.append("date", params.date);
            if (params.start_date) queryParams.append("start_date", params.start_date);
            if (params.end_date) queryParams.append("end_date", params.end_date);
            queryParams.append("page", params.page || 1);
            queryParams.append("limit", params.limit || 10); // 默认每页10条

            const queryString = queryParams.toString();
            const url = `/admin/plugins/points-mall/score_events?${queryString}`;

            const data = await ajax(url);
            const result = {
                events: data.events || [],
                total: data.total || 0,
                page: data.page || 1,
                limit: data.limit || 10, // 默认每页10条
            };
            return result;
        } catch (error) {
            popupAjaxError(error);
            return { events: [], total: 0, page: 1, limit: 10 };
        }
    }

    titleToken() {
        return i18n("points_mall.admin.score_events.title");
    }

    setupController(controller, model) {
        super.setupController(controller, model);
        // 确保 model 被正确设置，并同步到 tracked 属性
        if (model) {
            // 使用数组展开确保响应式更新
            controller.events = [...(model.events || [])];
            controller.total = model.total || 0;
            controller.currentPage = model.page || 1;
            // 同步 limit，确保分页计算正确
            if (model.limit) {
                controller.limit = model.limit;
            }
        }
    }
}

