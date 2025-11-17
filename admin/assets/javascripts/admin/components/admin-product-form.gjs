import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import DButton from "discourse/components/d-button";
import UppyImageUploader from "discourse/components/uppy-image-uploader";

export default class AdminProductForm extends Component {
  @service currentUser;

  @tracked name = "";
  @tracked description = "";
  @tracked uploadId = null;
  @tracked uploadUrl = null;
  @tracked stock = "";
  @tracked pointsRequired = "";
  @tracked active = true;
  @tracked sortOrder = "";
  @tracked productType = "physical";
  @tracked loading = false;

  constructor() {
    super(...arguments);
    if (this.args.product) {
      // 编辑模式
      this.name = this.args.product.name || "";
      this.description = this.args.product.description || "";
      this.uploadId = this.args.product.upload_id || null;
      this.uploadUrl = this.args.product.upload?.url || null;
      this.stock = this.args.product.stock?.toString() || "";
      this.pointsRequired = this.args.product.points_required?.toString() || "";
      this.active = this.args.product.active !== false;
      this.sortOrder = this.args.product.sort_order?.toString() || "0";
      this.productType = this.args.product.product_type || "physical";
    }
  }

  get isEditMode() {
    return !!this.args.product;
  }

  get formTitle() {
    return this.isEditMode
      ? i18n("points_mall.admin.products.edit")
      : i18n("points_mall.admin.products.add");
  }

  @action
  async uploadDone(upload) {
    this.uploadId = upload.id;
    this.uploadUrl = upload.url;
  }

  @action
  async submit() {
    if (this.loading) return;

    // 验证
    if (!this.name.trim()) {
      alert(i18n("points_mall.admin.products.name_required"));
      return;
    }
    if (!this.stock || isNaN(parseInt(this.stock)) || parseInt(this.stock) < 0) {
      alert(i18n("points_mall.admin.products.stock_required"));
      return;
    }
    if (!this.pointsRequired || isNaN(parseInt(this.pointsRequired)) || parseInt(this.pointsRequired) <= 0) {
      alert(i18n("points_mall.admin.products.points_required_required"));
      return;
    }

    this.loading = true;

    try {
      const data = {
        name: this.name.trim(),
        description: this.description || null,
        upload_id: this.uploadId || null,
        stock: parseInt(this.stock),
        points_required: parseInt(this.pointsRequired),
        active: this.active,
        sort_order: parseInt(this.sortOrder) || 0,
        product_type: this.productType || "physical",
      };

      if (this.isEditMode) {
        await this.args.onUpdate(this.args.product.id, data);
      } else {
        await this.args.onSave(data);
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }

  @action
  cancel() {
    this.args.onCancel?.();
  }

  @action
  updateName(event) {
    this.name = event.target.value;
  }

  @action
  updateDescription(event) {
    this.description = event.target.value;
  }

  @action
  updateStock(event) {
    this.stock = event.target.value;
  }

  @action
  updatePointsRequired(event) {
    this.pointsRequired = event.target.value;
  }

  @action
  updateActive(event) {
    this.active = event.target.checked;
  }

  @action
  updateSortOrder(event) {
    this.sortOrder = event.target.value;
  }

  @action
  updateProductType(event) {
    this.productType = event.target.value;
  }

  <template>
    <style>
      .product-form-container .product-form-input:focus {
        border-color: var(--tertiary) !important;
        outline: none;
      }
      .product-form-container .product-form-input:focus-visible {
        outline: 2px solid var(--tertiary);
        outline-offset: 2px;
      }
    </style>
    <div
      class="product-form-container"
      style="
        background: var(--secondary);
        border: 1px solid var(--primary-low);
        border-radius: 8px;
        padding: 24px;
        margin-bottom: 24px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
      "
    >
      <h3
        style="
          margin: 0 0 20px 0;
          font-size: 20px;
          font-weight: 600;
          color: var(--primary);
          border-bottom: 2px solid var(--primary-low);
          padding-bottom: 12px;
        "
      >
        {{this.formTitle}}
      </h3>
      <div
        class="product-form"
        style="display: flex; flex-direction: column; gap: 20px;"
      >
        <div class="form-row">
          <label
            style="
              display: flex;
              flex-direction: column;
              gap: 8px;
              font-weight: 500;
              color: var(--primary);
              font-size: 14px;
            "
          >
            {{i18n "points_mall.admin.products.name"}}
            <input
              type="text"
              value={{this.name}}
              placeholder={{i18n "points_mall.admin.products.name"}}
              required={{true}}
              {{on "input" this.updateName}}
              class="product-form-input"
              style="
                padding: 10px 12px;
                border: 1px solid var(--primary-low);
                border-radius: 4px;
                font-size: 14px;
                background: var(--secondary);
                color: var(--primary);
                transition: border-color 0.2s;
              "
            />
          </label>
        </div>

        <div class="form-row">
          <label
            style="
              display: flex;
              flex-direction: column;
              gap: 8px;
              font-weight: 500;
              color: var(--primary);
              font-size: 14px;
            "
          >
            {{i18n "points_mall.admin.products.product_type"}}
            <select
              value={{this.productType}}
              {{on "change" this.updateProductType}}
              class="product-form-input"
              style="
                padding: 10px 12px;
                border: 1px solid var(--primary-low);
                border-radius: 4px;
                font-size: 14px;
                background: var(--secondary);
                color: var(--primary);
                transition: border-color 0.2s;
              "
            >
              <option value="physical">
                {{i18n "points_mall.admin.products.product_type_physical"}}
              </option>
              <option value="virtual">
                {{i18n "points_mall.admin.products.product_type_virtual"}}
              </option>
            </select>
            <span style="font-size: 12px; color: var(--primary-medium);">
              {{i18n "points_mall.admin.products.product_type_hint"}}
            </span>
          </label>
        </div>

        <div class="form-row">
          <label
            style="
              display: flex;
              flex-direction: column;
              gap: 8px;
              font-weight: 500;
              color: var(--primary);
              font-size: 14px;
            "
          >
            {{i18n "points_mall.admin.products.description"}}
            <textarea
              value={{this.description}}
              placeholder={{i18n "points_mall.admin.products.description"}}
              {{on "input" this.updateDescription}}
              rows="4"
              class="product-form-input"
              style="
                padding: 10px 12px;
                border: 1px solid var(--primary-low);
                border-radius: 4px;
                font-size: 14px;
                background: var(--secondary);
                color: var(--primary);
                transition: border-color 0.2s;
                resize: vertical;
                font-family: inherit;
              "
            ></textarea>
          </label>
        </div>

        <div class="form-row">
          <label
            style="
              display: flex;
              flex-direction: column;
              gap: 8px;
              font-weight: 500;
              color: var(--primary);
              font-size: 14px;
            "
          >
            {{i18n "points_mall.admin.products.image"}}
            <UppyImageUploader
              @id="product-image-uploader"
              @type="composer"
              @imageUrl={{this.uploadUrl}}
              @onUploadDone={{this.uploadDone}}
            />
          </label>
        </div>

        <div
          style="
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
          "
        >
          <div class="form-row">
            <label
              style="
                display: flex;
                flex-direction: column;
                gap: 8px;
                font-weight: 500;
                color: var(--primary);
                font-size: 14px;
              "
            >
              {{i18n "points_mall.admin.products.stock"}}
              <input
                type="number"
                value={{this.stock}}
                placeholder={{i18n "points_mall.admin.products.stock"}}
                required={{true}}
                min="0"
                {{on "input" this.updateStock}}
                class="product-form-input"
                style="
                  padding: 10px 12px;
                  border: 1px solid var(--primary-low);
                  border-radius: 4px;
                  font-size: 14px;
                  background: var(--secondary);
                  color: var(--primary);
                  transition: border-color 0.2s;
                "
              />
            </label>
          </div>

          <div class="form-row">
            <label
              style="
                display: flex;
                flex-direction: column;
                gap: 8px;
                font-weight: 500;
                color: var(--primary);
                font-size: 14px;
              "
            >
              {{i18n "points_mall.admin.products.points_required"}}
              <input
                type="number"
                value={{this.pointsRequired}}
                placeholder={{i18n "points_mall.admin.products.points_required"}}
                required={{true}}
                min="1"
                {{on "input" this.updatePointsRequired}}
                class="product-form-input"
                style="
                  padding: 10px 12px;
                  border: 1px solid var(--primary-low);
                  border-radius: 4px;
                  font-size: 14px;
                  background: var(--secondary);
                  color: var(--primary);
                  transition: border-color 0.2s;
                "
              />
            </label>
          </div>
        </div>

        <div
          style="
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
          "
        >
          <div class="form-row">
            <label
              style="
                display: flex;
                flex-direction: column;
                gap: 8px;
                font-weight: 500;
                color: var(--primary);
                font-size: 14px;
              "
            >
              {{i18n "points_mall.admin.products.sort_order"}}
              <input
                type="number"
                value={{this.sortOrder}}
                placeholder="0"
                min="0"
                {{on "input" this.updateSortOrder}}
                class="product-form-input"
                style="
                  padding: 10px 12px;
                  border: 1px solid var(--primary-low);
                  border-radius: 4px;
                  font-size: 14px;
                  background: var(--secondary);
                  color: var(--primary);
                  transition: border-color 0.2s;
                "
              />
            </label>
          </div>

          <div class="form-row" style="display: flex; align-items: center; padding-top: 28px;">
            <label
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                font-weight: 500;
                color: var(--primary);
                font-size: 14px;
                cursor: pointer;
              "
            >
              <input
                type="checkbox"
                checked={{this.active}}
                {{on "change" this.updateActive}}
                style="width: 18px; height: 18px; cursor: pointer;"
              />
              {{i18n "points_mall.admin.products.active"}}
            </label>
          </div>
        </div>

        <div
          class="form-actions"
          style="
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 8px;
            padding-top: 20px;
            border-top: 1px solid var(--primary-low);
          "
        >
          <DButton
            @label="points_mall.admin.products.cancel"
            @action={{this.cancel}}
            @disabled={{this.loading}}
            class="btn-default"
          />
          <DButton
            @label="points_mall.admin.products.save"
            @action={{this.submit}}
            @disabled={{this.loading}}
            class="btn-primary"
          />
        </div>
      </div>
    </div>
  </template>
}

