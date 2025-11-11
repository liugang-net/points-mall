import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    <div class="points-mall-products">
      <div class="points-mall-products__header">
        <h1>{{i18n "points_mall.products.title"}}</h1>
        <div class="points-mall-products__score">
          {{i18n "points_mall.products.my_points"}}: <strong>{{@controller.formattedUserScore}}</strong>
        </div>
      </div>

      {{#if @controller.products.length}}
        <div class="points-mall-products__grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px;">
          {{#each @controller.products as |product|}}
            <div class="points-mall-product-card" style="border: 1px solid var(--primary-low); border-radius: 8px; padding: 16px; background: var(--secondary);">
              {{#if product.upload}}
                <div class="product-card__image" style="margin-bottom: 12px;">
                  <img src={{product.upload.url}} alt={{product.name}} style="width: 100%; height: 200px; object-fit: cover; border-radius: 4px;" />
                </div>
              {{/if}}
              <div class="product-card__content">
                <h3 class="product-card__name" style="margin-top: 0; margin-bottom: 8px;">{{product.name}}</h3>
                {{#if product.description}}
                  <p class="product-card__description" style="color: var(--primary-medium); margin-bottom: 12px;">{{product.description}}</p>
                {{/if}}
                <div class="product-card__info" style="margin-bottom: 16px;">
                  <div class="product-card__points" style="margin-bottom: 4px;">
                    {{i18n "points_mall.products.points_required"}}: <strong>{{product.formattedPointsRequired}}</strong>
                  </div>
                  <div class="product-card__stock">
                    {{i18n "points_mall.products.stock"}}: <strong>{{product.stock}}</strong>
                  </div>
                </div>
                <DButton
                  @label="points_mall.products.exchange"
                  @action={{fn @controller.showExchange product}}
                  class="btn-primary"
                  style="width: 100%;"
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
                />
              </div>
            {{/if}}
          </div>
        </div>
      {{/if}}
    </div>
  </template>
);

