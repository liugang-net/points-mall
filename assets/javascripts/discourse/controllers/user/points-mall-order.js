import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { number as formatNumber } from "discourse/lib/formatter";

export default class UserPointsMallOrderController extends Controller {
  @tracked order = null;

  formatNumber(value) {
    if (value == null || isNaN(value)) {
      return "0";
    }

    return formatNumber(value, { maxDisplay: 1000000 });
  }

  get isVirtualOrder() {
    const type =
      this.order?.product_type || this.order?.product?.product_type || "physical";
    return type === "virtual";
  }

  get hasRedemptionInfo() {
    return !!this.order?.redemption_info?.trim();
  }

  get redemptionInfoIsLink() {
    if (!this.hasRedemptionInfo) {
      return false;
    }

    return /^https?:\/\//i.test(this.order.redemption_info.trim());
  }
}

