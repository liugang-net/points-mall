import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PointsMallScoreEventsIndexController extends Controller {
    @service dialog;
    @service toasts;
    @service router;

    @tracked events = [];
    @tracked total = 0;
    @tracked currentPage = 1;
    @tracked limit = 50;
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
        const total = this.model?.total || this.total || 0;
        const limit = this.model?.limit || this.limit || 50;
        return Math.ceil(total / limit);
    }

    get hasNextPage() {
        const currentPage = this.model?.page || this.currentPage || 1;
        return currentPage < this.totalPages;
    }

    get hasPrevPage() {
        const currentPage = this.model?.page || this.currentPage || 1;
        return currentPage > 1;
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

            // 更新 model 和独立属性
            if (this.model) {
                this.model.events = data.events || [];
                this.model.total = data.total || 0;
                this.model.page = data.page || 1;
            }
            this.events = data.events || [];
            this.total = data.total || 0;
            this.currentPage = data.page || 1;
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
            await this.loadEvents(this.currentPage);
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
            await this.loadEvents(this.currentPage);
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

