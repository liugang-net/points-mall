import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

const DEFAULT_LIMIT = 20;

export default class UserPointsMallOrdersRoute extends DiscourseRoute {
  queryParams = {
    page: { refreshModel: true },
    status: { refreshModel: true },
  };

  model(params) {
    const page = params.page ? parseInt(params.page, 10) : 1;
    const data = { page: page || 1, limit: DEFAULT_LIMIT };
    if (params.status) {
      data.status = params.status;
    }

    return ajax("/points-mall/orders/my", { data });
  }

  setupController(controller, model) {
    super.setupController(controller, model);

    const queryParams = this.paramsFor(this.routeName);

    controller.orders = model?.orders || [];
    controller.total = model?.total || 0;
    controller.limit = model?.limit || DEFAULT_LIMIT;
    controller.page = queryParams.page
      ? parseInt(queryParams.page, 10)
      : 1;
    controller.status = queryParams.status || null;
  }
}

