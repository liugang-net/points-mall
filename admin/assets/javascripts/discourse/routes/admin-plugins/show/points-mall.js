import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

export default class PointsMallRoute extends DiscourseRoute {
    @service adminPluginNavManager;

    beforeModel() {
        // 跳转到第一个导航项（积分事件管理）
        this.transitionTo("adminPlugins.show.points-mall-score-events");
    }
}

