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
}

