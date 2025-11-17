import RouteTemplate from "ember-route-template";
import { LinkTo } from "@ember/routing";
import { concat } from "@ember/helper";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import { or } from "truth-helpers";

export default RouteTemplate(
  <template>
    {{#if @controller.order}}
      <div class="points-mall-user-order-detail">
        <div class="order-detail__header">
          <LinkTo
            @route="user.points-mall-orders"
            class="btn btn-link"
          >
            {{i18n "points_mall.user.orders.back"}}
          </LinkTo>
          <div class="order-detail__status">
            {{i18n
              (concat "points_mall.orders.status_" @controller.order.status)
            }}
          </div>
        </div>

        <div class="order-detail__summary">
          <div>
            <h2>
              {{i18n "points_mall.user.orders.detail_title"}}
              #{{@controller.order.id}}
            </h2>
            <p>
              {{i18n "points_mall.orders.created_at"}}:
              {{formatDate @controller.order.created_at}}
            </p>
            {{#if @controller.order.shipped_at}}
              <p>
                {{i18n "points_mall.orders.shipped_at"}}:
                {{formatDate @controller.order.shipped_at}}
              </p>
            {{/if}}
            {{#if @controller.order.completed_at}}
              <p>
                {{i18n "points_mall.orders.completed_at"}}:
                {{formatDate @controller.order.completed_at}}
              </p>
            {{/if}}
          </div>
          <div class="order-detail__points">
            <div>
              <span>{{i18n "points_mall.orders.points_spent"}}</span>
              <strong>
                {{@controller.formatNumber @controller.order.total_points_spent}}
              </strong>
            </div>
            <div>
              <span>{{i18n "points_mall.orders.quantity"}}</span>
              <strong>{{@controller.order.quantity}}</strong>
            </div>
          </div>
        </div>

        <div class="order-detail__content">
          <section>
            <h3>{{i18n "points_mall.user.orders.product_info"}}</h3>
            <div class="order-detail__product">
              {{#if @controller.order.product?.upload}}
                <img
                  src={{@controller.order.product.upload.url}}
                  alt={{@controller.order.product.name}}
                />
              {{/if}}
              <div>
                <p class="order-detail__product-name">
                  {{i18n "points_mall.orders.product"}}:
                  {{@controller.order.product_name}}
                </p>
              </div>
            </div>
          </section>

          {{#if @controller.isVirtualOrder}}
            <section>
              <h3>{{i18n "points_mall.orders.redemption_info"}}</h3>
              {{#if @controller.hasRedemptionInfo}}
                {{#if @controller.redemptionInfoIsLink}}
                  <a
                    href={{@controller.order.redemption_info}}
                    rel="noopener noreferrer"
                    target="_blank"
                    class="order-detail__redemption-link"
                  >
                    {{@controller.order.redemption_info}}
                  </a>
                {{else}}
                  <p class="order-detail__redemption">
                    {{@controller.order.redemption_info}}
                  </p>
                {{/if}}
              {{else}}
                <p class="order-detail__redemption order-detail__redemption--pending">
                  {{i18n "points_mall.orders.redemption_pending"}}
                </p>
              {{/if}}
            </section>
          {{else}}
            <section>
              <h3>{{i18n "points_mall.user.orders.recipient_info"}}</h3>
              <dl>
                <dt>{{i18n "points_mall.orders.recipient_name"}}</dt>
                <dd>{{@controller.order.recipient_name}}</dd>
                <dt>{{i18n "points_mall.orders.recipient_phone"}}</dt>
                <dd>{{@controller.order.recipient_phone}}</dd>
                <dt>{{i18n "points_mall.orders.recipient_address"}}</dt>
                <dd>{{@controller.order.recipient_address}}</dd>
              </dl>
            </section>

            <section>
              <h3>{{i18n "points_mall.user.orders.shipping_info"}}</h3>
              <dl>
                <dt>{{i18n "points_mall.orders.shipping_company"}}</dt>
                <dd>{{@controller.order.shipping_company}}</dd>
                <dt>{{i18n "points_mall.orders.shipping_number"}}</dt>
                <dd>{{@controller.order.shipping_number}}</dd>
              </dl>
            </section>
          {{/if}}

          {{#if @controller.order.admin_notes}}
            <section>
              <h3>{{i18n "points_mall.orders.admin_notes"}}</h3>
              <p>{{@controller.order.admin_notes}}</p>
            </section>
          {{/if}}
        </div>
      </div>
    {{else}}
      <div class="points-mall-user-orders__empty">
        {{i18n "points_mall.orders.no_orders"}}
      </div>
    {{/if}}
  </template>
);

