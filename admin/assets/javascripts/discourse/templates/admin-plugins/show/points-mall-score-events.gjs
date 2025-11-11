import { fn, gt, not } from "@ember/helper";
import { on } from "@ember/modifier";
import RouteTemplate from "ember-route-template";
import DBreadcrumbsItem from "discourse/components/d-breadcrumbs-item";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";
import AdminScoreEventForm from "discourse/plugins/points-mall/admin/components/admin-score-event-form";

export default RouteTemplate(
  <template>
    <DBreadcrumbsItem
      @path="/admin/plugins/points-mall/score-events"
      @label={{i18n "points_mall.admin.score_events.title"}}
    />

    <div class="points-mall__score-events admin-detail">
      <DPageSubheader
        @titleLabel={{i18n "points_mall.admin.score_events.title"}}
      >
        <:actions as |actions|>
          <actions.Primary
            @label="points_mall.admin.score_events.add"
            @title="points_mall.admin.score_events.add"
            @action={{@controller.showAddScoreForm}}
          />
        </:actions>
      </DPageSubheader>

      {{#if @controller.showAddForm}}
        <AdminScoreEventForm
          @event={{@controller.editingEvent}}
          @onSave={{@controller.addScoreEvent}}
          @onUpdate={{@controller.updateScoreEvent}}
          @onCancel={{@controller.hideAddForm}}
        />
      {{/if}}

      <div class="score-events">
        <div class="score-events__search">
          <div class="score-events__search-fields">
            <input
              type="text"
              value={{@controller.searchUserId}}
              placeholder={{i18n "points_mall.admin.score_events.user_id"}}
              class="search-field"
              {{on "input" @controller.updateSearchUserId}}
            />
            <input
              type="text"
              value={{@controller.searchUsername}}
              placeholder={{i18n "points_mall.admin.score_events.username"}}
              class="search-field"
              {{on "input" @controller.updateSearchUsername}}
            />
            <input
              type="date"
              value={{@controller.searchDate}}
              placeholder={{i18n "points_mall.admin.score_events.date"}}
              class="search-field"
              {{on "input" @controller.updateSearchDate}}
            />
            <input
              type="date"
              value={{@controller.searchStartDate}}
              placeholder={{i18n "points_mall.admin.score_events.start_date"}}
              class="search-field"
              {{on "input" @controller.updateSearchStartDate}}
            />
            <input
              type="date"
              value={{@controller.searchEndDate}}
              placeholder={{i18n "points_mall.admin.score_events.end_date"}}
              class="search-field"
              {{on "input" @controller.updateSearchEndDate}}
            />
            <DButton
              @label="points_mall.admin.score_events.search"
              @action={{@controller.search}}
              class="btn-primary"
            />
            <DButton
              @label="points_mall.admin.score_events.clear"
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
          {{#if @controller.displayEventsLength}}
            <table class="score-events__table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>{{i18n "points_mall.admin.score_events.user_id"}}</th>
                  <th>{{i18n "points_mall.admin.score_events.username"}}</th>
                  <th>{{i18n "points_mall.admin.score_events.date"}}</th>
                  <th>{{i18n "points_mall.admin.score_events.points"}}</th>
                  <th>{{i18n "points_mall.admin.score_events.description"}}</th>
                  <th>{{i18n "points_mall.admin.score_events.created_at"}}</th>
                  <th>{{i18n "points_mall.admin.score_events.actions"}}</th>
                </tr>
              </thead>
              <tbody>
                {{#each @controller.displayEvents as |event|}}
                  <tr>
                    <td>{{event.id}}</td>
                    <td>{{event.user_id}}</td>
                    <td>
                      {{#if event.user}}
                        {{event.user.username}}
                      {{else}}
                        -
                      {{/if}}
                    </td>
                    <td>{{event.date}}</td>
                    <td>{{event.points}}</td>
                    <td>{{event.description}}</td>
                    <td>{{event.created_at}}</td>
                    <td>
                      <div class="score-events__actions">
                        <DButton
                          @label="points_mall.admin.score_events.edit"
                          @action={{fn @controller.editEvent event}}
                          @disabled={{true}}
                          class="btn-small btn-text"
                        />
                        <DButton
                          @icon="trash-can"
                          @title="points_mall.admin.score_events.delete"
                          @action={{fn @controller.deleteEvent event}}
                          @disabled={{true}}
                          class="btn-small btn-danger"
                        />
                      </div>
                    </td>
                  </tr>
                {{/each}}
              </tbody>
            </table>

            <div class="score-events__pagination" style="margin-top: 20px; display: flex; justify-content: space-between; align-items: center;">
              <span>
                {{i18n "points_mall.admin.score_events.page_info"}}
                {{@controller.displayPage}}
                /
                {{@controller.totalPages}}
                ({{@controller.displayTotal}}
                {{i18n "points_mall.admin.score_events.total"}})
              </span>
              <div class="pagination-buttons">
                <DButton
                  @label="points_mall.admin.score_events.prev"
                  @action={{@controller.prevPage}}
                  @disabled={{@controller.canGoPrevPage}}
                  class="btn-default btn-small"
                />
                <DButton
                  @label="points_mall.admin.score_events.next"
                  @action={{@controller.nextPage}}
                  @disabled={{@controller.canGoNextPage}}
                  class="btn-default btn-small"
                />
              </div>
            </div>
          {{else}}
            <div class="admin-plugin-config-area__empty-list">
              <p class="text-center">暂无数据</p>
            </div>
          {{/if}}
        {{/if}}
      </div>
    </div>
  </template>
);
