import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PointsMallOrdersController extends Controller {
    @service dialog;
    @service toasts;
    @service router;
    @service modal;

    @tracked orders = [];
    @tracked total = 0;
    @tracked currentPage = 1;
    @tracked limit = 20;
    @tracked loading = false;
    @tracked selectedOrder = null;
    @tracked showShipModal = false;
    @tracked shippingOrder = null;
    @tracked shippingCompany = "";
    @tracked shippingNumber = "";
  @tracked redemptionInfo = "";

    // 查询条件
    @tracked searchUserId = "";
    @tracked searchUsername = "";
    @tracked searchStatus = "";
    @tracked searchStartDate = "";
    @tracked searchEndDate = "";

    get totalPages() {
        const total = this.total || 0;
        const limit = this.limit || 20;
        return Math.ceil(total / limit) || 1;
    }

    get hasNextPage() {
        const currentPage = this.currentPage || 1;
        return currentPage < this.totalPages;
    }

    get hasPrevPage() {
        const currentPage = this.currentPage || 1;
        return currentPage > 1;
    }

    get canGoPrevPage() {
        return !this.hasPrevPage;
    }

    get canGoNextPage() {
        return !this.hasNextPage;
    }

    get displayOrders() {
        return Array.isArray(this.orders) ? this.orders : [];
    }

    get displayOrdersLength() {
        return this.displayOrders.length;
    }

  get shippingOrderIsVirtual() {
    return this.shippingOrder?.product?.product_type === "virtual";
  }

    get displayTotal() {
        return this.total ?? 0;
    }

    get displayPage() {
        return this.currentPage ?? 1;
    }

    getStatusText(status) {
        const statusMap = {
            0: i18n("points_mall.admin.orders.status_pending"),
            1: i18n("points_mall.admin.orders.status_shipped"),
            2: i18n("points_mall.admin.orders.status_completed"),
            3: i18n("points_mall.admin.orders.status_cancelled"),
        };
        return statusMap[status] || status;
    }

    getStatusClass(status) {
        const classMap = {
            0: "status-pending",
            1: "status-shipped",
            2: "status-completed",
            3: "status-cancelled",
        };
        return classMap[status] || "";
    }

    // Helper method for template
    statusText(status) {
        return this.getStatusText(status);
    }

    @action
    async loadOrders(page = 1) {
        if (this.loading) return;

        this.loading = true;
        try {
            const queryParams = new URLSearchParams();
            if (this.searchUserId) queryParams.append("user_id", this.searchUserId);
            if (this.searchUsername) queryParams.append("username", this.searchUsername);
            if (this.searchStatus !== "") queryParams.append("status", this.searchStatus);
            if (this.searchStartDate) queryParams.append("start_date", this.searchStartDate);
            if (this.searchEndDate) queryParams.append("end_date", this.searchEndDate);
            queryParams.append("page", page);
            queryParams.append("limit", this.limit);

            const data = await ajax(
                `/admin/plugins/points-mall/orders?${queryParams.toString()}`
            );

            const newOrders = data.orders || [];
            const newTotal = data.total || 0;
            const newPage = data.page || 1;
            const newLimit = data.limit || this.limit || 20;

            // 为每个订单添加格式化后的状态文本和状态码
            const statusMap = {
                "pending": 0,
                "shipped": 1,
                "completed": 2,
                "cancelled": 3,
            };
            const ordersWithStatusText = newOrders.map(order => ({
                ...order,
                statusText: this.getStatusText(statusMap[order.status] ?? order.status),
                statusCode: statusMap[order.status] ?? order.status, // 添加状态码用于模板比较
            }));

            this.orders = [...ordersWithStatusText];
            this.total = newTotal;
            this.currentPage = newPage;
            this.limit = newLimit;

            if (this.model) {
                this.model.orders = [...ordersWithStatusText];
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
    async searchOrders() {
        await this.loadOrders(1);
    }

    @action
    clearSearch() {
        this.searchUserId = "";
        this.searchUsername = "";
        this.searchStatus = "";
        this.searchStartDate = "";
        this.searchEndDate = "";
        this.loadOrders(1);
    }

    @action
    openShipModal(order) {
        this.shippingOrder = order;
        this.shippingCompany = order.shipping_company || "";
        this.shippingNumber = order.shipping_number || "";
    this.redemptionInfo = order.redemption_info || "";
        this.showShipModal = true;
    }

    @action
    hideShipModal() {
        this.showShipModal = false;
        this.shippingOrder = null;
        this.shippingCompany = "";
        this.shippingNumber = "";
    this.redemptionInfo = "";
    }

    @action
    updateShippingCompany(event) {
        this.shippingCompany = event.target.value;
    }

    @action
    updateShippingNumber(event) {
        this.shippingNumber = event.target.value;
    }

  @action
  updateRedemptionInfo(event) {
    this.redemptionInfo = event.target.value;
  }

    @action
    async confirmShip() {
        if (!this.shippingOrder) return;

        try {
      const data = {
        status: 1,
      };

      if (this.shippingOrderIsVirtual) {
        const info = this.redemptionInfo?.trim();
        if (!info) {
          this.toasts.error({
            duration: 3000,
            data: {
              message: i18n("points_mall.admin.orders.redemption_info_required"),
            },
          });
          return;
        }
        data.redemption_info = info;
      } else {
        if (!this.shippingCompany?.trim() || !this.shippingNumber?.trim()) {
          this.toasts.error({
            duration: 3000,
            data: {
              message: i18n("points_mall.admin.orders.shipping_info_required"),
            },
          });
          return;
        }
        data.shipping_company = this.shippingCompany.trim();
        data.shipping_number = this.shippingNumber.trim();
      }

            await ajax(`/admin/plugins/points-mall/orders/${this.shippingOrder.id}/status`, {
                type: "PUT",
        data,
            });

            this.toasts.success({
                duration: 3000,
                data: {
                    message: i18n("points_mall.admin.orders.ship_success"),
                },
            });

            this.hideShipModal();
            await this.loadOrders(this.currentPage);
        } catch (error) {
            popupAjaxError(error);
        }
    }

    @action
    async updateOrderStatus(order, newStatus) {
        // 如果是发货，显示模态框让用户输入快递信息
        if (newStatus === 1) {
            this.openShipModal(order);
            return;
        }

        const confirmMessages = {
            2: i18n("points_mall.admin.orders.complete_confirm"),
            3: i18n("points_mall.admin.orders.cancel_confirm"),
        };

        const successMessages = {
            2: i18n("points_mall.admin.orders.complete_success"),
            3: i18n("points_mall.admin.orders.cancel_success"),
        };

        this.dialog.yesNoConfirm({
            message: confirmMessages[newStatus],
            didConfirm: async () => {
                try {
                    await ajax(`/admin/plugins/points-mall/orders/${order.id}/status`, {
                        type: "PUT",
                        data: { status: newStatus },
                    });

                    this.toasts.success({
                        duration: 3000,
                        data: {
                            message: successMessages[newStatus],
                        },
                    });

                    await this.loadOrders(this.currentPage);
                } catch (error) {
                    popupAjaxError(error);
                }
            },
        });
    }

    @action
    async updateOrder(order, data) {
        try {
            await ajax(`/admin/plugins/points-mall/orders/${order.id}`, {
                type: "PUT",
                data: data,
            });

            this.toasts.success({
                duration: 3000,
                data: {
                    message: i18n("points_mall.admin.orders.update_order_success"),
                },
            });

            await this.loadOrders(this.currentPage);
        } catch (error) {
            popupAjaxError(error);
        }
    }

    @action
    showOrderDetails(order) {
        this.selectedOrder = order;
    }

    @action
    hideOrderDetails() {
        this.selectedOrder = null;
    }

    @action
    async nextPage() {
        if (this.hasNextPage) {
            await this.loadOrders(this.currentPage + 1);
        }
    }

    @action
    async prevPage() {
        if (this.hasPrevPage) {
            await this.loadOrders(this.currentPage - 1);
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
    updateSearchStatus(event) {
        this.searchStatus = event.target.value;
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

