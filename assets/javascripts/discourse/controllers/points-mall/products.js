import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import DModal from "discourse/components/d-modal";
import { number as formatNumber } from "discourse/lib/formatter";

export default class PointsMallProductsController extends Controller {
    @service currentUser;
    @service router;
    @service modal;
    @service toasts;

    @tracked products = [];
    @tracked userScore = 0;
    @tracked selectedProduct = null;
    @tracked showExchangeModal = false;
    @tracked exchangeQuantity = 1;
    @tracked recipientName = "";
    @tracked recipientPhone = "";
    @tracked recipientAddress = "";
    @tracked userNotes = "";
    @tracked loading = false;

    get canExchange() {
        if (!this.selectedProduct) return false;
        const requiredPoints = this.selectedProduct.points_required * this.exchangeQuantity;
        return (
            this.selectedProduct.can_purchase &&
            this.selectedProduct.stock >= this.exchangeQuantity &&
            this.userScore >= requiredPoints &&
            this.recipientName.trim() &&
            this.recipientPhone.trim() &&
            this.recipientAddress.trim()
        );
    }

    get totalPointsRequired() {
        if (!this.selectedProduct) return 0;
        return this.selectedProduct.points_required * this.exchangeQuantity;
    }

    formatNumber(value) {
        if (value == null || isNaN(value)) return "0";
        return formatNumber(value, { maxDisplay: 1000000 });
    }

    get formattedUserScore() {
        return this.formatNumber(this.userScore);
    }

    get formattedTotalPointsRequired() {
        return this.formatNumber(this.totalPointsRequired);
    }

    get exchangeButtonTitle() {
        if (!this.canExchange) {
            return i18n("points_mall.products.cannot_exchange");
        }
        return "";
    }

    formatProductPoints(product) {
        if (!product || !product.points_required) return "0";
        return this.formatNumber(product.points_required);
    }

    @action
    showExchange(product) {
        // 检查用户是否登录
        if (!this.currentUser) {
            this.toasts.error({
                duration: 3000,
                data: {
                    message: i18n("points_mall.products.login_required"),
                },
            });
            return;
        }

        // 确保 selectedProduct 有格式化后的属性
        this.selectedProduct = {
            ...product,
            formattedPointsRequired: product.formattedPointsRequired || this.formatNumber(product.points_required || 0),
        };
        this.exchangeQuantity = 1;
        this.recipientName = "";
        this.recipientPhone = "";
        this.recipientAddress = "";
        this.userNotes = "";
        this.showExchangeModal = true;
    }

    @action
    hideExchange() {
        this.showExchangeModal = false;
        this.selectedProduct = null;
    }

    @action
    async confirmExchange() {
        if (this.loading) return;

        // 检查是否可以兑换，如果不行则显示错误提示
        if (!this.canExchange) {
            if (!this.selectedProduct) {
                this.toasts.error({
                    duration: 3000,
                    data: {
                        message: i18n("points_mall.products.no_product_selected"),
                    },
                });
                return;
            }

            const requiredPoints = this.selectedProduct.points_required * this.exchangeQuantity;
            if (this.userScore < requiredPoints) {
                const message = i18n("points_mall.products.insufficient_points", {
                    required: this.formattedTotalPointsRequired,
                    current: this.formattedUserScore,
                });
                this.toasts.error({
                    duration: 3000,
                    data: {
                        message: message,
                    },
                });
                return;
            }

            if (this.selectedProduct.stock < this.exchangeQuantity) {
                this.toasts.error({
                    duration: 3000,
                    data: {
                        message: i18n("points_mall.products.out_of_stock"),
                    },
                });
                return;
            }

            if (!this.recipientName.trim() || !this.recipientPhone.trim() || !this.recipientAddress.trim()) {
                this.toasts.error({
                    duration: 3000,
                    data: {
                        message: i18n("points_mall.products.recipient_info_required"),
                    },
                });
                return;
            }
        }

        this.loading = true;
        try {
            const response = await ajax("/points-mall/orders", {
                type: "POST",
                data: {
                    product_id: this.selectedProduct.id,
                    quantity: this.exchangeQuantity,
                    recipient_name: this.recipientName.trim(),
                    recipient_phone: this.recipientPhone.trim(),
                    recipient_address: this.recipientAddress.trim(),
                    user_notes: this.userNotes.trim() || null,
                },
            });

            // 更新用户积分（从后端返回的最新积分）
            if (response && response.user_current_score !== undefined) {
                // 更新控制器中的积分
                this.userScore = response.user_current_score;
                // 更新 currentUser 对象中的积分，这样重新进入页面时也会显示最新值
                if (this.currentUser) {
                    this.currentUser.setProperties({
                        gamification_score: response.user_current_score,
                    });
                }
            } else if (this.currentUser?.gamification_score !== undefined) {
                // 如果后端没有返回，尝试从 currentUser 获取
                this.userScore = this.currentUser.gamification_score;
            }

            this.toasts.success({
                duration: 3000,
                data: {
                    message: i18n("points_mall.products.exchange_success"),
                },
            });

            this.hideExchange();

            // 刷新商品列表（更新库存）
            // 注意：不调用 router.refresh()，因为它会重新执行 setupController 并覆盖 userScore
            // 只刷新商品数据，保持 userScore 的更新
            try {
                const productsData = await ajax("/points-mall/products.json");
                const formatPoints = (value) => {
                    if (value == null || isNaN(value)) return "0";
                    return formatNumber(value, { maxDisplay: 1000000 });
                };
                const updatedProducts = (productsData.products || []).map(product => ({
                    ...product,
                    formattedPointsRequired: formatPoints(product.points_required),
                }));
                this.products = updatedProducts;
            } catch (error) {
                // 如果刷新商品列表失败，仍然刷新整个路由
                await this.router.refresh();
                // refresh 后再次确保 userScore 是最新的
                if (response && response.user_current_score !== undefined) {
                    this.userScore = response.user_current_score;
                }
            }
        } catch (error) {
            popupAjaxError(error);
        } finally {
            this.loading = false;
        }
    }

    @action
    updateQuantity(event) {
        const value = parseInt(event.target.value) || 1;
        this.exchangeQuantity = Math.max(1, Math.min(value, this.selectedProduct?.stock || 1));
    }

    @action
    updateRecipientName(event) {
        this.recipientName = event.target.value;
    }

    @action
    updateRecipientPhone(event) {
        this.recipientPhone = event.target.value;
    }

    @action
    updateRecipientAddress(event) {
        this.recipientAddress = event.target.value;
    }

    @action
    updateUserNotes(event) {
        this.userNotes = event.target.value;
    }
}

