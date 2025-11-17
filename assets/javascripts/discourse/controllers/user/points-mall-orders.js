import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { number as formatNumber } from "discourse/lib/formatter";

const MIN_PAGE = 1;

export default class UserPointsMallOrdersController extends Controller {
  queryParams = ["page", "status"];

  @tracked page = MIN_PAGE;
  @tracked status = null;

  @tracked orders = [];
  @tracked total = 0;
  @tracked limit = 20;

  get hasOrders() {
    return this.orders.length > 0;
  }

  get totalPages() {
    if (!this.limit) {
      return MIN_PAGE;
    }
    return Math.max(MIN_PAGE, Math.ceil(this.total / this.limit));
  }

  get hasMultiplePages() {
    return this.totalPages > 1;
  }

  get canGoPrevious() {
    return this.page > MIN_PAGE;
  }

  get canGoNext() {
    return this.page < this.totalPages;
  }

  formatNumber(value) {
    if (value == null || isNaN(value)) {
      return "0";
    }

    return formatNumber(value, { maxDisplay: 1000000 });
  }

  @action
  changeStatus(event) {
    const value = event.target.value?.trim();
    this.status = value ? value : null;
    this.page = MIN_PAGE;
  }

  @action
  previousPage() {
    if (this.canGoPrevious) {
      this.page = this.page - 1;
    }
  }

  @action
  nextPage() {
    if (this.canGoNext) {
      this.page = this.page + 1;
    }
  }
}

