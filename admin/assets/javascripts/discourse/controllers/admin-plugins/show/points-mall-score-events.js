import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PointsMallScoreEventsController extends Controller {
    @service dialog;
    @service toasts;
    @service router;

    @tracked events = [];
    @tracked total = 0;
    @tracked currentPage = 1;
    @tracked limit = 10; // 默认每页10条，便于测试分页
    @tracked loading = false;
    @tracked showAddForm = false;
    @tracked editingEvent = null;

    // 查询条件
    @tracked searchUserId = "";
    @tracked searchUsername = "";
    @tracked searchDate = "";
    @tracked searchStartDate = "";
    @tracked searchEndDate = "";

    get totalPages() {
        // 始终使用 tracked 属性，确保响应式更新
        const total = this.total || 0;
        const limit = this.limit || 10;
        return Math.ceil(total / limit) || 1; // 至少1页
    }

    get hasNextPage() {
        // 始终使用 tracked 属性，确保响应式更新
        const currentPage = this.currentPage || 1;
        return currentPage < this.totalPages;
    }

    get hasPrevPage() {
        // 始终使用 tracked 属性，确保响应式更新
        const currentPage = this.currentPage || 1;
        return currentPage > 1;
    }

    get canGoPrevPage() {
        // 返回 true 表示禁用按钮
        return !this.hasPrevPage;
    }

    get canGoNextPage() {
        // 返回 true 表示禁用按钮
        return !this.hasNextPage;
    }

    // 获取积分的 class 名称
    getPointsClass(points) {
        return points > 0 ? "points-positive" : "points-negative";
    }

    // 格式化积分显示（正数显示 +）
    formatPoints(points) {
        return points > 0 ? `+${points}` : points.toString();
    }

    // 获取事件列表，始终使用 tracked 属性（响应式）
    get displayEvents() {
        // 始终使用 tracked 属性，确保响应式更新
        return Array.isArray(this.events) ? this.events : [];
    }

    // 获取事件数量
    get displayEventsLength() {
        return this.displayEvents.length;
    }

    // 获取总数，始终使用 tracked 属性
    get displayTotal() {
        return this.total ?? 0;
    }

    // 获取当前页，始终使用 tracked 属性
    get displayPage() {
        return this.currentPage ?? 1;
    }


    @action
    async loadEvents(page = 1) {
        if (this.loading) return;

        this.loading = true;
        try {
            const queryParams = new URLSearchParams();
            if (this.searchUserId) queryParams.append("user_id", this.searchUserId);
            if (this.searchUsername) queryParams.append("username", this.searchUsername);
            if (this.searchDate) queryParams.append("date", this.searchDate);
            if (this.searchStartDate) queryParams.append("start_date", this.searchStartDate);
            if (this.searchEndDate) queryParams.append("end_date", this.searchEndDate);
            queryParams.append("page", page);
            queryParams.append("limit", this.limit);

            const data = await ajax(
                `/admin/plugins/points-mall/score_events?${queryParams.toString()}`
            );

            // 更新 tracked 属性（响应式）
            const newEvents = data.events || [];
            const newTotal = data.total || 0;
            const newPage = data.page || 1;
            const newLimit = data.limit || this.limit || 10;

            // 使用数组替换来确保响应式更新
            this.events = [...newEvents];
            this.total = newTotal;
            this.currentPage = newPage;
            this.limit = newLimit;

            // 同时更新 model（如果存在）
            if (this.model) {
                this.model.events = [...newEvents];
                this.model.total = newTotal;
                this.model.page = newPage;
                this.model.limit = newLimit;
            }
        } catch (error) {
            popupAjaxError(error);
        } finally {
            this.loading = false;
        }
    }

    @action
    async search() {
        await this.loadEvents(1);
    }

    @action
    clearSearch() {
        this.searchUserId = "";
        this.searchUsername = "";
        this.searchDate = "";
        this.searchStartDate = "";
        this.searchEndDate = "";
        this.loadEvents(1);
    }

    @action
    showAddScoreForm() {
        this.showAddForm = true;
        this.editingEvent = null;
    }

    @action
    hideAddForm() {
        this.showAddForm = false;
        this.editingEvent = null;
    }

    @action
    async addScoreEvent(data) {
        try {
            await ajax("/admin/plugins/points-mall/score_events", {
                type: "POST",
                data,
            });

            this.toasts.success({
                duration: 3000,
                data: {
                    message: i18n("points_mall.admin.score_events.add_success"),
                },
            });

            this.hideAddForm();
            // 刷新列表，新添加的事件通常在第一页，所以刷新第一页
            await this.loadEvents(1);
        } catch (error) {
            popupAjaxError(error);
        }
    }

    @action
    editEvent(event) {
        this.editingEvent = event;
        this.showAddForm = true;
    }

    @action
    async updateScoreEvent(eventId, data) {
        try {
            await ajax(`/admin/plugins/points-mall/score_events/${eventId}`, {
                type: "PUT",
                data,
            });

            this.toasts.success({
                duration: 3000,
                data: {
                    message: i18n("points_mall.admin.score_events.update_success"),
                },
            });

            this.hideAddForm();
            // 刷新列表，保持当前页
            const pageToLoad = this.displayPage || this.currentPage || 1;
            await this.loadEvents(pageToLoad);
        } catch (error) {
            popupAjaxError(error);
        }
    }

    @action
    async deleteEvent(event) {
        this.dialog.deleteConfirm({
            message: i18n("points_mall.admin.score_events.delete_confirm"),
            didConfirm: async () => {
                try {
                    await ajax(
                        `/admin/plugins/points-mall/score_events/${event.id}`,
                        {
                            type: "DELETE",
                        }
                    );

                    this.toasts.success({
                        duration: 3000,
                        data: {
                            message: i18n("points_mall.admin.score_events.delete_success"),
                        },
                    });

                    await this.loadEvents(this.currentPage);
                } catch (error) {
                    popupAjaxError(error);
                }
            },
        });
    }

    @action
    async nextPage() {
        if (this.hasNextPage) {
            await this.loadEvents(this.currentPage + 1);
        }
    }

    @action
    async prevPage() {
        if (this.hasPrevPage) {
            await this.loadEvents(this.currentPage - 1);
        }
    }

    @action
    updateSearchUserId(event) {
        this.searchUserId = event.target.value;
    }

    @action
    updateSearchUsername(event) {
        this.searchUsername = event.target.value;
    }

    @action
    updateSearchDate(event) {
        this.searchDate = event.target.value;
    }

    @action
    updateSearchStartDate(event) {
        this.searchStartDate = event.target.value;
    }

    @action
    updateSearchEndDate(event) {
        this.searchEndDate = event.target.value;
    }
}
