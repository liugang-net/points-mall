import { fn } from "@ember/helper";
import { eq } from "truth-helpers";
import { on } from "@ember/modifier";
import RouteTemplate from "ember-route-template";
import DBreadcrumbsItem from "discourse/components/d-breadcrumbs-item";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";
import AdminOrderDetailsModal from "discourse/plugins/points-mall/admin/components/admin-order-details-modal";

export default RouteTemplate(
  <template>
    <DBreadcrumbsItem
      @path="/admin/plugins/points-mall/orders-page"
      @label={{i18n "points_mall.admin.orders.title"}}
    />

    <div class="points-mall__orders admin-detail">
      <DPageSubheader
        @titleLabel={{i18n "points_mall.admin.orders.title"}}
      />

      <div class="orders">
        <div class="orders__search">
          <div class="orders__search-fields">
            <input
              type="text"
              value={{@controller.searchUserId}}
              placeholder={{i18n "points_mall.admin.orders.user"}}
              class="search-field"
              {{on "input" @controller.updateSearchUserId}}
            />
            <input
              type="text"
              value={{@controller.searchUsername}}
              placeholder={{i18n "points_mall.admin.orders.user"}}
              class="search-field"
              {{on "input" @controller.updateSearchUsername}}
            />
            <select
              value={{@controller.searchStatus}}
              {{on "change" @controller.updateSearchStatus}}
              class="search-field"
            >
              <option value="">{{i18n "points_mall.admin.orders.status"}}</option>
              <option value="0">{{i18n "points_mall.admin.orders.status_pending"}}</option>
              <option value="1">{{i18n "points_mall.admin.orders.status_shipped"}}</option>
              <option value="2">{{i18n "points_mall.admin.orders.status_completed"}}</option>
              <option value="3">{{i18n "points_mall.admin.orders.status_cancelled"}}</option>
            </select>
            <input
              type="date"
              value={{@controller.searchStartDate}}
              placeholder={{i18n "points_mall.admin.orders.created_at"}}
              class="search-field"
              {{on "input" @controller.updateSearchStartDate}}
            />
            <input
              type="date"
              value={{@controller.searchEndDate}}
              placeholder={{i18n "points_mall.admin.orders.created_at"}}
              class="search-field"
              {{on "input" @controller.updateSearchEndDate}}
            />
            <DButton
              @label="points_mall.admin.orders.search"
              @action={{@controller.searchOrders}}
              class="btn-primary"
            />
            <DButton
              @label="points_mall.admin.orders.clear"
              @action={{@controller.clearSearch}}
              class="btn-default"
            />
          </div>
        </div>

        {{#if @controller.loading}}
          <div class="loading-container">
            <div class="spinner"></div>
          </div>
        {{else}}
          {{#if @controller.displayOrdersLength}}
            <table class="orders__table">
              <thead>
                <tr>
                  <th style="width: 80px;">{{i18n "points_mall.admin.orders.order_id"}}</th>
                  <th style="width: 120px;">{{i18n "points_mall.admin.orders.user"}}</th>
                  <th style="width: 200px;">{{i18n "points_mall.admin.orders.product"}}</th>
                  <th style="width: 80px;">{{i18n "points_mall.admin.orders.quantity"}}</th>
                  <th style="width: 100px;">{{i18n "points_mall.admin.orders.points_spent"}}</th>
                  <th style="width: 100px;">{{i18n "points_mall.admin.orders.status"}}</th>
                  <th style="width: 150px;">{{i18n "points_mall.admin.orders.created_at"}}</th>
                  <th style="width: 200px;">{{i18n "points_mall.admin.orders.actions"}}</th>
                </tr>
              </thead>
              <tbody>
                {{#each @controller.displayOrders as |order|}}
                  <tr>
                    <td>
                      <a href="#" {{on "click" (fn @controller.showOrderDetails order)}} style="color: var(--tertiary); text-decoration: underline; cursor: pointer;">
                        #{{order.id}}
                      </a>
                    </td>
                    <td>
                      {{#if order.user}}
                        {{order.user.username}}
                      {{else}}
                        {{order.user_id}}
                      {{/if}}
                    </td>
                    <td>
                      {{#if order.product}}
                        <div style="display: flex; align-items: center; gap: 8px;">
                          {{#if order.product.upload}}
                            <img src={{order.product.upload.url}} alt={{order.product.name}} style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px;" />
                          {{/if}}
                          <span style="font-weight: 500;">{{order.product.name}}</span>
                        </div>
                      {{else}}
                        {{order.product_id}}
                      {{/if}}
                    </td>
                    <td>{{order.quantity}}</td>
                    <td><strong>{{order.total_points_spent}}</strong></td>
                    <td>
                      <span class="order-status-badge order-status-{{order.statusCode}}" style="
                        display: inline-block;
                        padding: 4px 8px;
                        border-radius: 4px;
                        font-size: 12px;
                        font-weight: 500;
                      ">
                        {{order.statusText}}
                      </span>
                    </td>
                    <td style="font-size: 12px; color: var(--primary-medium);">
                      {{order.created_at}}
                    </td>
                    <td>
                      <div class="orders__actions" style="display: flex; gap: 4px; flex-wrap: wrap;">
                        {{#if (eq order.statusCode 0)}}
                          <DButton
                            @label="points_mall.admin.orders.ship"
                            @action={{fn @controller.updateOrderStatus order 1}}
                            class="btn-small btn-primary"
                          />
                          <DButton
                            @label="points_mall.admin.orders.cancel"
                            @action={{fn @controller.updateOrderStatus order 3}}
                            class="btn-small btn-danger"
                          />
                        {{/if}}
                        {{#if (eq order.statusCode 1)}}
                          <DButton
                            @label="points_mall.admin.orders.complete"
                            @action={{fn @controller.updateOrderStatus order 2}}
                            class="btn-small btn-primary"
                          />
                        {{/if}}
                        <DButton
                          @label="points_mall.admin.orders.details"
                          @action={{fn @controller.showOrderDetails order}}
                          class="btn-small btn-text"
                        />
                      </div>
                    </td>
                  </tr>
                {{/each}}
              </tbody>
            </table>

            <div class="orders__pagination" style="margin-top: 20px; display: flex; justify-content: space-between; align-items: center;">
              <span>
                {{i18n "points_mall.admin.orders.page_info"}}
                {{@controller.displayPage}}
                /
                {{@controller.totalPages}}
                ({{@controller.displayTotal}}
                {{i18n "points_mall.admin.orders.total"}})
              </span>
              <div class="pagination-buttons">
                <DButton
                  @label="points_mall.admin.orders.prev"
                  @action={{@controller.prevPage}}
                  @disabled={{@controller.canGoPrevPage}}
                  class="btn-default btn-small"
                />
                <DButton
                  @label="points_mall.admin.orders.next"
                  @action={{@controller.nextPage}}
                  @disabled={{@controller.canGoNextPage}}
                  class="btn-default btn-small"
                />
              </div>
            </div>
          {{else}}
            <div class="admin-plugin-config-area__empty-list">
              <p class="text-center">{{i18n "points_mall.admin.orders.no_orders"}}</p>
            </div>
          {{/if}}
        {{/if}}
      </div>

      {{#if @controller.selectedOrder}}
              <AdminOrderDetailsModal
                @order={{@controller.selectedOrder}}
                @onClose={{@controller.hideOrderDetails}}
                @onUpdateOrder={{@controller.updateOrder}}
                @getStatusText={{@controller.getStatusText}}
              />
      {{/if}}

      {{#if @controller.showShipModal}}
        <div class="ship-modal-overlay" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center;">
          <div class="ship-modal" style="background: var(--secondary); padding: 24px; border-radius: 8px; max-width: 500px; width: 90%;">
            <h2 style="margin-top: 0;">{{i18n "points_mall.admin.orders.ship_order"}}</h2>
            
            {{#if @controller.shippingOrder}}
              <div class="ship-modal__order-info" style="margin-bottom: 20px; padding: 12px; background: var(--primary-low); border-radius: 4px;">
                <div><strong>{{i18n "points_mall.admin.orders.order_id"}}:</strong> {{@controller.shippingOrder.id}}</div>
                <div><strong>{{i18n "points_mall.admin.orders.product"}}:</strong> {{@controller.shippingOrder.product.name}}</div>
                <div><strong>{{i18n "points_mall.admin.orders.recipient_name"}}:</strong> {{@controller.shippingOrder.recipient_name}}</div>
              </div>

              <div class="ship-modal__form" style="display: flex; flex-direction: column; gap: 16px;">
                {{#if @controller.shippingOrderIsVirtual}}
                  <div>
                    <label style="display: block; margin-bottom: 4px; font-weight: 500;">
                      {{i18n "points_mall.admin.orders.redemption_info"}}
                    </label>
                    <textarea
                      value={{@controller.redemptionInfo}}
                      placeholder={{i18n "points_mall.admin.orders.redemption_info_placeholder"}}
                      {{on "input" @controller.updateRedemptionInfo}}
                      style="width: 100%; min-height: 80px; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px;"
                    ></textarea>
                  </div>
                {{else}}
                  <div>
                    <label style="display: block; margin-bottom: 4px; font-weight: 500;">
                      {{i18n "points_mall.admin.orders.shipping_company"}}
                    </label>
                    <input
                      type="text"
                      value={{@controller.shippingCompany}}
                      placeholder={{i18n "points_mall.admin.orders.shipping_company_placeholder"}}
                      {{on "input" @controller.updateShippingCompany}}
                      style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px;"
                    />
                  </div>

                  <div>
                    <label style="display: block; margin-bottom: 4px; font-weight: 500;">
                      {{i18n "points_mall.admin.orders.shipping_number"}}
                    </label>
                    <input
                      type="text"
                      value={{@controller.shippingNumber}}
                      placeholder={{i18n "points_mall.admin.orders.shipping_number_placeholder"}}
                      {{on "input" @controller.updateShippingNumber}}
                      style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px;"
                    />
                  </div>
                {{/if}}
              </div>

              <div style="display: flex; gap: 12px; margin-top: 20px; justify-content: flex-end;">
                <DButton
                  @label="points_mall.admin.products.cancel"
                  @action={{@controller.hideShipModal}}
                  class="btn-default"
                />
                <DButton
                  @label="points_mall.admin.orders.ship"
                  @action={{@controller.confirmShip}}
                  class="btn-primary"
                />
              </div>
            {{/if}}
          </div>
        </div>
      {{/if}}
    </div>
  </template>
);

