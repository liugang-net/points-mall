import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    <div class="points-mall-products">
      <div class="points-mall-products__header">
        <h1 class="sr-only">{{i18n "points_mall.products.title"}}</h1>
        {{#if @controller.currentUser}}
          <div class="points-mall-products__score">
            <span>{{i18n "points_mall.products.my_points"}}</span>
            <strong>{{@controller.formattedUserScore}}</strong>
          </div>
        {{/if}}
      </div>

      {{#if @controller.products.length}}
        <div class="points-mall-products__grid">
          {{#each @controller.products as |product|}}
            <div class="points-mall-product-card">
              {{#if product.upload}}
                <div class="points-mall-product-card__image">
                  <img src={{product.upload.url}} alt={{product.name}} />
                </div>
              {{/if}}
              <div class="points-mall-product-card__content">
                <h3 class="points-mall-product-card__name">{{product.name}}</h3>
                {{#if product.description}}
                  <p class="points-mall-product-card__description">{{product.description}}</p>
                {{/if}}
                <div class="points-mall-product-card__info">
                  <div class="points-mall-product-card__points">
                    <span>{{i18n "points_mall.products.points_required"}}</span>
                    <strong>{{product.formattedPointsRequired}}</strong>
                  </div>
                  <div class="points-mall-product-card__stock">
                    <span>{{i18n "points_mall.products.stock"}}</span>
                    <strong>{{product.stock}}</strong>
                  </div>
                </div>
                <DButton
                  @label="points_mall.products.exchange"
                  @action={{fn @controller.showExchange product}}
                  class="btn-primary points-mall-product-card__exchange-btn"
                />
              </div>
            </div>
          {{/each}}
        </div>
      {{else}}
        <div class="empty-state" style="text-align: center; padding: 40px; color: var(--primary-medium);">
          <p>{{i18n "points_mall.products.no_products"}}</p>
        </div>
      {{/if}}

      {{#if @controller.showExchangeModal}}
        <div class="exchange-modal-overlay" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center;">
          <div class="exchange-modal" style="background: var(--secondary); padding: 24px; border-radius: 8px; max-width: 500px; width: 90%; max-height: 90vh; overflow-y: auto;">
            <h2 style="margin-top: 0;">{{i18n "points_mall.products.exchange_confirm"}}</h2>
            
            {{#if @controller.selectedProduct}}
              <div class="exchange-modal__product">
                <h3>{{@controller.selectedProduct.name}}</h3>
                <div>
                  {{i18n "points_mall.products.points_required"}}: {{@controller.selectedProduct.formattedPointsRequired}} × {{@controller.exchangeQuantity}} = {{@controller.formattedTotalPointsRequired}}
                </div>
              </div>

              <div class="exchange-modal__form" style="display: flex; flex-direction: column; gap: 16px; margin-top: 20px;">
                <div>
                  <label style="display: block; margin-bottom: 4px; font-weight: 500;">
                    {{i18n "points_mall.products.quantity"}}
                  </label>
                  <input
                    type="number"
                    value={{@controller.exchangeQuantity}}
                    min="1"
                    max={{@controller.selectedProduct.stock}}
                    {{on "input" @controller.updateQuantity}}
                    style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px;"
                  />
                </div>

                {{#if @controller.requiresShipping}}
                  <div>
                    <label style="display: block; margin-bottom: 4px; font-weight: 500;">
                      {{i18n "points_mall.products.recipient_name"}} <span style="color: red;">*</span>
                    </label>
                    <input
                      type="text"
                      value={{@controller.recipientName}}
                      placeholder={{i18n "points_mall.products.recipient_name"}}
                      required={{true}}
                      {{on "input" @controller.updateRecipientName}}
                      style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px;"
                    />
                  </div>

                  <div>
                    <label style="display: block; margin-bottom: 4px; font-weight: 500;">
                      {{i18n "points_mall.products.recipient_phone"}} <span style="color: red;">*</span>
                    </label>
                    <input
                      type="text"
                      value={{@controller.recipientPhone}}
                      placeholder={{i18n "points_mall.products.recipient_phone"}}
                      required={{true}}
                      {{on "input" @controller.updateRecipientPhone}}
                      style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px;"
                    />
                  </div>

                  <div>
                    <label style="display: block; margin-bottom: 4px; font-weight: 500;">
                      {{i18n "points_mall.products.recipient_address"}} <span style="color: red;">*</span>
                    </label>
                    <textarea
                      value={{@controller.recipientAddress}}
                      placeholder={{i18n "points_mall.products.recipient_address"}}
                      required={{true}}
                      rows="3"
                      {{on "input" @controller.updateRecipientAddress}}
                      style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px; resize: vertical;"
                    ></textarea>
                  </div>
                {{else}}
                  <div
                    class="virtual-delivery-hint"
                    style="padding: 12px; background: var(--primary-very-low); border-radius: 4px; color: var(--primary-medium);"
                  >
                    {{i18n "points_mall.products.virtual_delivery_hint"}}
                  </div>
                {{/if}}

                <div>
                  <label style="display: block; margin-bottom: 4px; font-weight: 500;">
                    {{i18n "points_mall.products.user_notes"}}
                  </label>
                  <textarea
                    value={{@controller.userNotes}}
                    placeholder={{i18n "points_mall.products.user_notes"}}
                    rows="2"
                    {{on "input" @controller.updateUserNotes}}
                    style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px; resize: vertical;"
                  ></textarea>
                </div>

                <div style="padding: 12px; background: var(--primary-low); border-radius: 4px;">
                  <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                    <span>{{i18n "points_mall.products.total_points"}}:</span>
                    <strong>{{@controller.formattedTotalPointsRequired}}</strong>
                  </div>
                  <div style="display: flex; justify-content: space-between;">
                    <span>{{i18n "points_mall.products.my_points"}}:</span>
                    <strong>{{@controller.formattedUserScore}}</strong>
                  </div>
                </div>
              </div>

              <div style="display: flex; gap: 12px; margin-top: 20px; justify-content: flex-end;">
                <DButton
                  @label="points_mall.admin.products.cancel"
                  @action={{@controller.hideExchange}}
                  @disabled={{@controller.loading}}
                  class="btn-default"
                />
                <DButton
                  @label="points_mall.products.exchange"
                  @action={{@controller.confirmExchange}}
                  @disabled={{@controller.loading}}
                  class="btn-primary"
                  title={{@controller.exchangeButtonTitle}}
                />
              </div>
            {{/if}}
          </div>
        </div>
      {{/if}}
    </div>
  </template>
);
