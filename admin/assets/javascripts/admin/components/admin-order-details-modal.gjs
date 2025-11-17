import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { i18n } from "discourse-i18n";
import DButton from "discourse/components/d-button";

export default class AdminOrderDetailsModal extends Component {
  @tracked adminNotes = "";
  @tracked shippingCompany = "";
  @tracked shippingNumber = "";
  @tracked redemptionInfo = "";

  constructor() {
    super(...arguments);
    this.adminNotes = this.args.order?.admin_notes || "";
    this.shippingCompany = this.args.order?.shipping_company || "";
    this.shippingNumber = this.args.order?.shipping_number || "";
    this.redemptionInfo = this.args.order?.redemption_info || "";
  }

  get isVirtualOrder() {
    return (
      this.args.order?.product?.product_type === "virtual" ||
      this.args.order?.product_type === "virtual"
    );
  }

  @action
  updateAdminNotes(event) {
    this.adminNotes = event.target.value;
  }

  @action
  updateShippingCompany(event) {
    this.shippingCompany = event.target.value;
  }

  @action
  updateShippingNumber(event) {
    this.shippingNumber = event.target.value;
  }

  @action
  updateRedemptionInfo(event) {
    this.redemptionInfo = event.target.value;
  }

  @action
  async saveOrder() {
    await this.args.onUpdateOrder(this.args.order, {
      admin_notes: this.adminNotes,
      shipping_company: this.shippingCompany,
      shipping_number: this.shippingNumber,
      redemption_info: this.redemptionInfo,
    });
    this.args.onClose();
  }

  @action
  stopPropagation(event) {
    event.stopPropagation();
  }

  <template>
    <div class="order-details-modal-overlay" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center;" {{on "click" (fn this.args.onClose)}}>
      <div style="background: var(--secondary); padding: 24px; border-radius: 8px; max-width: 600px; max-height: 80vh; overflow-y: auto; position: relative;" {{on "click" this.stopPropagation}}>
        <h3 style="margin-top: 0;">{{i18n "points_mall.admin.orders.order_id"}} #{{@order.id}}</h3>
        <div style="display: flex; flex-direction: column; gap: 12px;">
          <div><strong>{{i18n "points_mall.admin.orders.user"}}:</strong> {{@order.user.username}}</div>
          <div><strong>{{i18n "points_mall.admin.orders.product"}}:</strong> {{@order.product.name}}</div>
          <div><strong>{{i18n "points_mall.admin.orders.quantity"}}:</strong> {{@order.quantity}}</div>
          <div><strong>{{i18n "points_mall.admin.orders.points_spent"}}:</strong> {{@order.total_points_spent}}</div>
          <div><strong>{{i18n "points_mall.admin.orders.status"}}:</strong> {{@getStatusText @order.status}}</div>
          <div><strong>{{i18n "points_mall.admin.orders.recipient_name"}}:</strong> {{@order.recipient_name}}</div>
          <div><strong>{{i18n "points_mall.admin.orders.recipient_phone"}}:</strong> {{@order.recipient_phone}}</div>
          <div><strong>{{i18n "points_mall.admin.orders.recipient_address"}}:</strong> {{@order.recipient_address}}</div>
          {{#if @order.user_notes}}
            <div><strong>{{i18n "points_mall.admin.orders.user_notes"}}:</strong> {{@order.user_notes}}</div>
          {{/if}}
          {{#if this.isVirtualOrder}}
            <div>
              <strong>{{i18n "points_mall.admin.orders.redemption_info"}}:</strong>
              <textarea
                value={{this.redemptionInfo}}
                placeholder={{i18n "points_mall.admin.orders.redemption_info_placeholder"}}
                {{on "input" this.updateRedemptionInfo}}
                style="width: 100%; min-height: 80px; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px; margin-top: 8px;"
              ></textarea>
            </div>
          {{else}}
            <div>
              <strong>{{i18n "points_mall.admin.orders.shipping_company"}}:</strong>
              <input
                type="text"
                value={{this.shippingCompany}}
                placeholder={{i18n "points_mall.admin.orders.shipping_company_placeholder"}}
                {{on "input" this.updateShippingCompany}}
                style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px; margin-top: 8px;"
              />
            </div>
            <div>
              <strong>{{i18n "points_mall.admin.orders.shipping_number"}}:</strong>
              <input
                type="text"
                value={{this.shippingNumber}}
                placeholder={{i18n "points_mall.admin.orders.shipping_number_placeholder"}}
                {{on "input" this.updateShippingNumber}}
                style="width: 100%; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px; margin-top: 8px;"
              />
            </div>
          {{/if}}
          <div>
            <strong>{{i18n "points_mall.admin.orders.admin_notes"}}:</strong>
            <textarea
              value={{this.adminNotes}}
              {{on "input" this.updateAdminNotes}}
              style="width: 100%; min-height: 80px; padding: 8px; border: 1px solid var(--primary-low); border-radius: 4px; margin-top: 8px;"
            ></textarea>
          </div>
        </div>
        <div style="display: flex; gap: 12px; margin-top: 20px; justify-content: flex-end;">
          <DButton
            @label="points_mall.admin.products.cancel"
            @action={{@onClose}}
            class="btn-default"
          />
          <DButton
            @label="points_mall.admin.orders.update_order"
            @action={{this.saveOrder}}
            class="btn-primary"
          />
        </div>
      </div>
    </div>
  </template>
}

