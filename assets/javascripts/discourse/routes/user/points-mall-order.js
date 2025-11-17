import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class UserPointsMallOrderRoute extends DiscourseRoute {
  model(params) {
    return ajax(`/points-mall/orders/${params.order_id}`);
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.order = model;
  }
}

