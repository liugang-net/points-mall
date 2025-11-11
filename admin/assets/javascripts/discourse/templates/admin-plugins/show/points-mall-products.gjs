import { fn, gt, not } from "@ember/helper";
import { on } from "@ember/modifier";
import RouteTemplate from "ember-route-template";
import DBreadcrumbsItem from "discourse/components/d-breadcrumbs-item";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";
import AdminProductForm from "discourse/plugins/points-mall/admin/components/admin-product-form";

export default RouteTemplate(
  <template>
    <DBreadcrumbsItem
      @path="/admin/plugins/points-mall/products-page"
      @label={{i18n "points_mall.admin.products.title"}}
    />

    <div class="points-mall__products admin-detail">
      <DPageSubheader
        @titleLabel={{i18n "points_mall.admin.products.title"}}
      >
        <:actions as |actions|>
          <actions.Primary
            @label="points_mall.admin.products.add"
            @title="points_mall.admin.products.add"
            @action={{@controller.showAddProductForm}}
          />
        </:actions>
      </DPageSubheader>

      <div style="margin-bottom: 20px; display: flex; gap: 10px; align-items: center;">
        <DButton
          @label="points_mall.admin.products.view_mall"
          @title="points_mall.admin.products.view_mall"
          @action={{@controller.viewMall}}
          class="btn-default"
        />
      </div>

      {{#if @controller.showAddForm}}
        <AdminProductForm
          @product={{@controller.editingProduct}}
          @onSave={{@controller.addProduct}}
          @onUpdate={{@controller.updateProduct}}
          @onCancel={{@controller.hideAddForm}}
        />
      {{/if}}

      <div class="products">
        <div class="products__search">
          <div class="products__search-fields">
            <input
              type="text"
              value={{@controller.search}}
              placeholder={{i18n "points_mall.admin.products.name"}}
              class="search-field"
              {{on "input" @controller.updateSearch}}
            />
            <select
              value={{@controller.active}}
              {{on "change" @controller.updateActive}}
              class="search-field"
            >
              <option value="">{{i18n "points_mall.admin.products.active"}}</option>
              <option value="true">{{i18n "yes_value"}}</option>
              <option value="false">{{i18n "no_value"}}</option>
            </select>
            <DButton
              @label="points_mall.admin.products.search"
              @action={{@controller.searchProducts}}
              class="btn-primary"
            />
            <DButton
              @label="points_mall.admin.products.clear"
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
          {{#if @controller.displayProductsLength}}
            <table class="products__table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>{{i18n "points_mall.admin.products.name"}}</th>
                  <th>{{i18n "points_mall.admin.products.image"}}</th>
                  <th>{{i18n "points_mall.admin.products.stock"}}</th>
                  <th>{{i18n "points_mall.admin.products.points_required"}}</th>
                  <th>{{i18n "points_mall.admin.products.active"}}</th>
                  <th>{{i18n "points_mall.admin.products.created_at"}}</th>
                  <th>{{i18n "points_mall.admin.products.actions"}}</th>
                </tr>
              </thead>
              <tbody>
                {{#each @controller.displayProducts as |product|}}
                  <tr>
                    <td>{{product.id}}</td>
                    <td>{{product.name}}</td>
                    <td>
                      {{#if product.upload}}
                        <img src={{product.upload.url}} alt={{product.name}} style="width: 50px; height: 50px; object-fit: cover;" />
                      {{else}}
                        -
                      {{/if}}
                    </td>
                    <td>{{product.stock}}</td>
                    <td>{{product.points_required}}</td>
                    <td>{{if product.active (i18n "yes_value") (i18n "no_value")}}</td>
                    <td>{{product.created_at}}</td>
                    <td>
                      <div class="products__actions">
                        <DButton
                          @label="points_mall.admin.products.edit"
                          @action={{fn @controller.editProduct product}}
                          class="btn-small btn-text"
                        />
                        <DButton
                          @icon="trash-can"
                          @title="points_mall.admin.products.delete"
                          @action={{fn @controller.deleteProduct product}}
                          class="btn-small btn-danger"
                        />
                      </div>
                    </td>
                  </tr>
                {{/each}}
              </tbody>
            </table>

            <div class="products__pagination" style="margin-top: 20px; display: flex; justify-content: space-between; align-items: center;">
              <span>
                {{i18n "points_mall.admin.products.page_info"}}
                {{@controller.displayPage}}
                /
                {{@controller.totalPages}}
                ({{@controller.displayTotal}}
                {{i18n "points_mall.admin.products.total"}})
              </span>
              <div class="pagination-buttons">
                <DButton
                  @label="points_mall.admin.products.prev"
                  @action={{@controller.prevPage}}
                  @disabled={{@controller.canGoPrevPage}}
                  class="btn-default btn-small"
                />
                <DButton
                  @label="points_mall.admin.products.next"
                  @action={{@controller.nextPage}}
                  @disabled={{@controller.canGoNextPage}}
                  class="btn-default btn-small"
                />
              </div>
            </div>
          {{else}}
            <div class="admin-plugin-config-area__empty-list">
              <p class="text-center">{{i18n "points_mall.admin.products.no_products"}}</p>
            </div>
          {{/if}}
        {{/if}}
      </div>
    </div>
  </template>
);

