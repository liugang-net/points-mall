import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PointsMallProductsController extends Controller {
    @service dialog;
    @service toasts;
    @service router;

    @tracked products = [];
    @tracked total = 0;
    @tracked currentPage = 1;
    @tracked limit = 20;
    @tracked loading = false;
    @tracked showAddForm = false;
    @tracked editingProduct = null;

    // 查询条件
    @tracked search = "";
    @tracked active = "";

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

    get displayProducts() {
        return Array.isArray(this.products) ? this.products : [];
    }

    get displayProductsLength() {
        return this.displayProducts.length;
    }

    get displayTotal() {
        return this.total ?? 0;
    }

    get displayPage() {
        return this.currentPage ?? 1;
    }

    @action
    async loadProducts(page = 1) {
        if (this.loading) return;

        this.loading = true;
        try {
            const queryParams = new URLSearchParams();
            if (this.search) queryParams.append("search", this.search);
            if (this.active !== "") queryParams.append("active", this.active);
            queryParams.append("page", page);
            queryParams.append("limit", this.limit);

            const data = await ajax(
                `/admin/plugins/points-mall/products?${queryParams.toString()}`
            );

            const newProducts = data.products || [];
            const newTotal = data.total || 0;
            const newPage = data.page || 1;
            const newLimit = data.limit || this.limit || 20;

            this.products = [...newProducts];
            this.total = newTotal;
            this.currentPage = newPage;
            this.limit = newLimit;

            if (this.model) {
                this.model.products = [...newProducts];
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
    async searchProducts() {
        await this.loadProducts(1);
    }

    @action
    clearSearch() {
        this.search = "";
        this.active = "";
        this.loadProducts(1);
    }

    @action
    showAddProductForm() {
        this.showAddForm = true;
        this.editingProduct = null;
    }

    @action
    hideAddForm() {
        this.showAddForm = false;
        this.editingProduct = null;
    }

    @action
    async addProduct(data) {
        try {
            await ajax("/admin/plugins/points-mall/products", {
                type: "POST",
                data,
            });

            this.toasts.success({
                duration: 3000,
                data: {
                    message: i18n("points_mall.admin.products.add_success"),
                },
            });

            this.hideAddForm();
            await this.loadProducts(1);
        } catch (error) {
            popupAjaxError(error);
        }
    }

    @action
    editProduct(product) {
        this.editingProduct = product;
        this.showAddForm = true;
    }

    @action
    async updateProduct(productId, data) {
        try {
            await ajax(`/admin/plugins/points-mall/products/${productId}`, {
                type: "PUT",
                data,
            });

            this.toasts.success({
                duration: 3000,
                data: {
                    message: i18n("points_mall.admin.products.update_success"),
                },
            });

            this.hideAddForm();
            const pageToLoad = this.displayPage || this.currentPage || 1;
            await this.loadProducts(pageToLoad);
        } catch (error) {
            popupAjaxError(error);
        }
    }

    @action
    async deleteProduct(product) {
        this.dialog.deleteConfirm({
            message: i18n("points_mall.admin.products.delete_confirm"),
            didConfirm: async () => {
                try {
                    await ajax(
                        `/admin/plugins/points-mall/products/${product.id}`,
                        {
                            type: "DELETE",
                        }
                    );

                    this.toasts.success({
                        duration: 3000,
                        data: {
                            message: i18n("points_mall.admin.products.delete_success"),
                        },
                    });

                    await this.loadProducts(this.currentPage);
                } catch (error) {
                    popupAjaxError(error);
                }
            },
        });
    }

    @action
    async nextPage() {
        if (this.hasNextPage) {
            await this.loadProducts(this.currentPage + 1);
        }
    }

    @action
    async prevPage() {
        if (this.hasPrevPage) {
            await this.loadProducts(this.currentPage - 1);
        }
    }

    @action
    updateSearch(event) {
        this.search = event.target.value;
    }

    @action
    updateActive(event) {
        this.active = event.target.value;
    }

    @action
    viewMall() {
        // 跳转到前端商城页面（使用 router 进行客户端路由跳转）
        this.router.transitionTo("points-mall.products");
    }
}

