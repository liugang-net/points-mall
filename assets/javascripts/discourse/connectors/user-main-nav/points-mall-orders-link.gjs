/* eslint-disable ember/no-classic-components */
import Component from "@ember/component";
import { LinkTo } from "@ember/routing";
import { classNames, tagName } from "@ember-decorators/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

@tagName("li")
@classNames("user-main-nav-outlet", "points-mall-orders-nav")
export default class PointsMallOrdersLink extends Component {
  @service currentUser;

  get viewingSelf() {
    return (
      this.currentUser &&
      this.model &&
      this.currentUser.username_lower === this.model.username_lower
    );
  }

  <template>
    {{#if this.viewingSelf}}
      <LinkTo @route="user.points-mall-orders">
        {{icon "discourse-table"}}
        <span>{{i18n "points_mall.user.orders.nav"}}</span>
      </LinkTo>
    {{/if}}
  </template>
}

