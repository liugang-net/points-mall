import { array, concat, fn } from "@ember/helper";
import { on } from "@ember/modifier";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import { eq } from "discourse/truth-helpers";
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

      <nav class="points-mall-products__filters" aria-label={{i18n "points_mall.products.filter_label"}}>
        {{#each (array "all" "virtual" "physical") as |productType|}}
          <button
            type="button"
            class={{if
              (eq @controller.productTypeFilter productType)
              "points-mall-products__filter is-active"
              "points-mall-products__filter"
            }}
            aria-pressed={{if (eq @controller.productTypeFilter productType) "true" "false"}}
            {{on "click" (fn @controller.setProductTypeFilter productType)}}
          >
            {{i18n (concat "points_mall.products.filter_" productType)}}
          </button>
        {{/each}}
      </nav>

      {{#if @controller.products.length}}
        <div class="points-mall-products__grid">
          {{#each @controller.filteredProducts as |product|}}
            <div class="points-mall-product-card">
              <div class="points-mall-product-card__image">
                <span class="points-mall-product-card__stock">
                  {{i18n "points_mall.products.stock"}}-<strong>{{product.stock}}</strong>
                </span>
                {{#if product.upload}}
                  <img src={{product.upload.url}} alt={{product.name}} />
                {{/if}}
              </div>
              <div class="points-mall-product-card__content">
                <h3 class="points-mall-product-card__name">{{product.name}}</h3>
                {{#if product.description}}
                  <p class="points-mall-product-card__description">{{product.description}}</p>
                {{/if}}
                <div class="points-mall-product-card__info">
                  <div class="points-mall-product-card__points">
                    {{icon "ibomy-points"}}
                    <strong>{{product.formattedPointsRequired}}</strong>
                    <span class="points-mall-product-card__points-unit">
                      {{i18n "points_mall.products.points_unit"}}
                    </span>
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
        <div class="exchange-modal-overlay" role="presentation">
          <section class="exchange-modal" role="dialog" aria-modal="true" aria-labelledby="exchange-modal-title">
            <header class="exchange-modal__header">
              <h2 id="exchange-modal-title">{{i18n "points_mall.products.exchange_confirm"}}</h2>
              <button
                type="button"
                class="exchange-modal__close"
                aria-label={{i18n "points_mall.admin.products.cancel"}}
                {{on "click" @controller.hideExchange}}
              >×</button>
            </header>

            {{#if @controller.selectedProduct}}
              <div class="exchange-modal__product">
                <div class="exchange-modal__product-image">
                  {{#if @controller.selectedProduct.upload}}
                    <img src={{@controller.selectedProduct.upload.url}} alt={{@controller.selectedProduct.name}} />
                  {{/if}}
                </div>
                <div class="exchange-modal__product-summary">
                  <div class="exchange-modal__product-heading">
                    <h3>{{@controller.selectedProduct.name}}</h3>
                    <div class="exchange-modal__quantity">
                      <button type="button" {{on "click" @controller.decreaseQuantity}}>−</button>
                      <input
                        aria-label={{i18n "points_mall.products.quantity"}}
                        type="number"
                        value={{@controller.exchangeQuantity}}
                        min="1"
                        max={{@controller.selectedProduct.stock}}
                        {{on "input" @controller.updateQuantity}}
                      />
                      <button type="button" {{on "click" @controller.increaseQuantity}}>+</button>
                    </div>
                  </div>
                  <div class="exchange-modal__points">
                    <span>{{icon "ibomy-points"}}{{i18n "points_mall.products.points_cost"}}</span>
                    <strong>{{@controller.formattedTotalPointsRequired}}</strong>
                  </div>
                </div>
              </div>

              <div class="exchange-modal__form">
                {{#if @controller.requiresShipping}}
                  <div class="exchange-modal__shipping-title">
                    <span class="exchange-modal__location">{{icon "ibomy-address"}}</span>
                    {{i18n "points_mall.products.shipping_title"}}
                  </div>
                  <div class="exchange-modal__shipping-fields">
                    <label>
                      <span><b>*</b>{{i18n "points_mall.products.recipient_name"}}</span>
                    <input
                      type="text"
                      value={{@controller.recipientName}}
                      placeholder={{i18n "points_mall.products.recipient_name"}}
                      required={{true}}
                      {{on "input" @controller.updateRecipientName}}
                    />
                    </label>
                    <label>
                      <span><b>*</b>{{i18n "points_mall.products.recipient_phone"}}</span>
                    <input
                      type="tel"
                      value={{@controller.recipientPhone}}
                      placeholder={{i18n "points_mall.products.recipient_phone"}}
                      required={{true}}
                      {{on "input" @controller.updateRecipientPhone}}
                    />
                    </label>
                    <label>
                      <span><b>*</b>{{i18n "points_mall.products.recipient_address"}}</span>
                    <input
                      type="text"
                      value={{@controller.recipientAddress}}
                      placeholder={{i18n "points_mall.products.recipient_address"}}
                      required={{true}}
                      {{on "input" @controller.updateRecipientAddress}}
                    />
                    </label>
                  </div>
                {{else}}
                  <div class="virtual-delivery-hint">
                    {{i18n "points_mall.products.virtual_delivery_hint"}}
                  </div>
                {{/if}}

                <label class="exchange-modal__notes">
                  <strong>{{i18n "points_mall.products.user_notes"}}</strong>
                  <span class="exchange-modal__notes-field">
                  <textarea
                    value={{@controller.userNotes}}
                    placeholder={{i18n "points_mall.products.user_notes"}}
                    rows="2"
                    maxlength="50"
                    {{on "input" @controller.updateUserNotes}}
                  ></textarea>
                    <small>{{@controller.notesLength}}/50</small>
                  </span>
                </label>
              </div>

              <footer class="exchange-modal__footer">
                <DButton
                  @translatedLabel={{@controller.confirmButtonLabel}}
                  @action={{@controller.confirmExchange}}
                  @disabled={{@controller.confirmDisabled}}
                  class={{if @controller.hasEnoughPoints "exchange-modal__submit" "exchange-modal__submit is-insufficient"}}
                  title={{@controller.exchangeButtonTitle}}
                />
              </footer>
            {{/if}}
          </section>
        </div>
      {{/if}}
    </div>
  </template>
);
