import RouteTemplate from "ember-route-template";
import { LinkTo } from "@ember/routing";
import { on } from "@ember/modifier";
import { concat } from "@ember/helper";
import DButton from "discourse/components/d-button";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import { not } from "truth-helpers";

export default RouteTemplate(
  <template>
    <div class="points-mall-user-orders">
      <div class="points-mall-user-orders__header">
        <h1>{{i18n "points_mall.user.orders.title"}}</h1>
        <div class="points-mall-user-orders__filters">
          <label>
            <span>{{i18n "points_mall.user.orders.status_filter"}}</span>
            <select
              value={{@controller.status}}
              {{on "change" @controller.changeStatus}}
            >
              <option value="">
                {{i18n "points_mall.user.orders.status_all"}}
              </option>
              <option value="pending">
                {{i18n "points_mall.orders.status_pending"}}
              </option>
              <option value="shipped">
                {{i18n "points_mall.orders.status_shipped"}}
              </option>
              <option value="completed">
                {{i18n "points_mall.orders.status_completed"}}
              </option>
              <option value="cancelled">
                {{i18n "points_mall.orders.status_cancelled"}}
              </option>
            </select>
          </label>
        </div>
      </div>

      {{#if @controller.hasOrders}}
        <div class="points-mall-user-orders__grid">
          {{#each @controller.orders as |order|}}
            <div class="points-mall-user-orders__card">
              <div class="order-card__header">
                <div class="order-card__id">
                  {{i18n "points_mall.orders.order_id"}} #{{order.id}}
                </div>
                <div class="order-card__status">
                  {{i18n (concat "points_mall.orders.status_" order.status)}}
                </div>
              </div>

              <div class="order-card__body">
                <div class="order-card__product">
                  {{#if order.product?.upload}}
                    <img
                      src={{order.product.upload.url}}
                      alt={{order.product.name}}
                    />
                  {{/if}}
                  <div>
                    <h3>{{order.product?.name}}</h3>
                    {{#if order.product?.description}}
                      <p>{{order.product.description}}</p>
                    {{/if}}
                  </div>
                </div>

                <div class="order-card__meta">
                  <div>
                    <span>{{i18n "points_mall.orders.quantity"}}</span>
                    <strong>{{order.quantity}}</strong>
                  </div>
                  <div>
                    <span>{{i18n "points_mall.orders.points_spent"}}</span>
                    <strong>
                      {{@controller.formatNumber order.total_points_spent}}
                    </strong>
                  </div>
                  <div>
                    <span>{{i18n "points_mall.orders.created_at"}}</span>
                    <strong>{{formatDate order.created_at}}</strong>
                  </div>
                </div>
              </div>

              <div class="order-card__actions">
                <LinkTo
                  @route="user.points-mall-order"
                  @model={{order.id}}
                  class="btn btn-link"
                >
                  {{i18n "points_mall.user.orders.view_details"}}
                </LinkTo>
              </div>
            </div>
          {{/each}}
        </div>
      {{else}}
        <div class="points-mall-user-orders__empty">
          {{i18n "points_mall.orders.no_orders"}}
        </div>
      {{/if}}

      {{#if @controller.hasMultiplePages}}
        <div class="points-mall-user-orders__pagination">
          <DButton
            @action={{@controller.previousPage}}
            @disabled={{not @controller.canGoPrevious}}
            @label="points_mall.user.orders.prev"
            class="btn-default"
          />
          <span class="page-indicator">
            {{@controller.page}} / {{@controller.totalPages}}
          </span>
          <DButton
            @action={{@controller.nextPage}}
            @disabled={{not @controller.canGoNext}}
            @label="points_mall.user.orders.next"
            class="btn-default"
          />
        </div>
      {{/if}}
    </div>
  </template>
);

