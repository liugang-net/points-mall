import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class AdminScoreEventForm extends Component {
  @service dialog;

  @tracked userId = "";
  @tracked username = "";
  @tracked date = "";
  @tracked points = "";
  @tracked description = "";
  @tracked loading = false;
  @tracked searchingUser = false;
  @tracked userResults = [];

  constructor() {
    super(...arguments);
    if (this.args.event) {
      // 编辑模式
      this.userId = this.args.event.user_id?.toString() || "";
      this.username = this.args.event.user?.username || "";
      this.date = this.args.event.date || "";
      this.points = this.args.event.points?.toString() || "";
      this.description = this.args.event.description || "";
    } else {
      // 新增模式，设置默认日期为今天
      const today = new Date();
      this.date = today.toISOString().split("T")[0];
    }
  }

  get isEditMode() {
    return !!this.args.event;
  }

  get formTitle() {
    return this.isEditMode
      ? i18n("points_mall.admin.score_events.edit")
      : i18n("points_mall.admin.score_events.add");
  }

  @action
  async searchUsers(query) {
    if (!query || query.length < 2) {
      this.userResults = [];
      return;
    }

    this.searchingUser = true;
    try {
      const data = await ajax("/admin/users.json", {
        data: { filter: query, limit: 10 },
      });

      this.userResults = data || [];
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.searchingUser = false;
    }
  }

  @action
  selectUser(user) {
    this.userId = user.id.toString();
    this.username = user.username || "";
    this.userResults = [];
  }

  @action
  async submit() {
    if (this.loading) {
      return;
    }

    // 验证
    if (!this.userId && !this.username) {
      this.dialog.alert(i18n("points_mall.admin.score_events.user_required"));
      return;
    }
    if (!this.date) {
      this.dialog.alert(i18n("points_mall.admin.score_events.date_required"));
      return;
    }
    if (!this.points || isNaN(parseInt(this.points, 10))) {
      this.dialog.alert(i18n("points_mall.admin.score_events.points_required"));
      return;
    }

    this.loading = true;

    try {
      const data = {
        date: this.date,
        points: parseInt(this.points, 10),
        description: this.description,
      };

      if (this.userId) {
        data.user_id = parseInt(this.userId, 10);
      } else if (this.username) {
        data.username = this.username;
      }

      if (this.isEditMode) {
        await this.args.onUpdate(this.args.event.id, data);
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
  updateUserId(event) {
    this.userId = event.target.value;
    if (this.userId) {
      this.username = "";
      this.userResults = [];
    }
  }

  @action
  updateUsername(event) {
    this.username = event.target.value;
    if (this.username) {
      this.userId = "";
      this.searchUsers(this.username);
    } else {
      this.userResults = [];
    }
  }

  @action
  updateDate(event) {
    this.date = event.target.value;
  }

  @action
  updatePoints(event) {
    this.points = event.target.value;
  }

  @action
  updateDescription(event) {
    this.description = event.target.value;
  }

  <template>
    <div
      class="score-event-form-container"
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
        class="score-event-form"
        style="display: flex; flex-direction: column; gap: 20px;"
      >
        <div
          style="
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
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
              {{i18n "points_mall.admin.score_events.user_id"}}
              <input
                type="text"
                value={{this.userId}}
                placeholder={{i18n "points_mall.admin.score_events.user_id"}}
                disabled={{this.isEditMode}}
                {{on "input" this.updateUserId}}
                class="score-event-form-input"
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

          <div class="form-row" style="position: relative;">
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
              {{i18n "points_mall.admin.score_events.username"}}
              <input
                type="text"
                value={{this.username}}
                placeholder={{i18n "points_mall.admin.score_events.username"}}
                disabled={{this.isEditMode}}
                {{on "input" this.updateUsername}}
                class="score-event-form-input"
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

            {{#if this.userResults.length}}
              <div
                class="score-event-form-user-results"
                style="
                  position: absolute;
                  top: calc(100% + 4px);
                  left: 0;
                  right: 0;
                  background: var(--secondary);
                  border: 1px solid var(--primary-low);
                  border-radius: 4px;
                  max-height: 240px;
                  overflow: auto;
                  z-index: 10;
                  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.12);
                "
              >
                {{#each this.userResults as |user|}}
                  <button
                    type="button"
                    {{on "click" (fn this.selectUser user)}}
                    style="
                      display: flex;
                      justify-content: space-between;
                      width: 100%;
                      padding: 10px 12px;
                      border: 0;
                      background: transparent;
                      text-align: left;
                      cursor: pointer;
                    "
                  >
                    <span style="color: var(--primary); font-weight: 500;">
                      {{user.username}}
                    </span>
                    <span style="color: var(--primary-medium);">
                      #{{user.id}}
                    </span>
                  </button>
                {{/each}}
              </div>
            {{/if}}
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
              {{i18n "points_mall.admin.score_events.date"}}
              <input
                type="date"
                value={{this.date}}
                required={{true}}
                disabled={{true}}
                class="score-event-form-input"
                style="
                  padding: 10px 12px;
                  border: 1px solid var(--primary-low);
                  border-radius: 4px;
                  font-size: 14px;
                  background: var(--primary-low);
                  color: var(--primary-medium);
                  transition: border-color 0.2s;
                  cursor: not-allowed;
                "
              />
            </label>
          </div>
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
            {{i18n "points_mall.admin.score_events.points"}}
            <input
              type="number"
              value={{this.points}}
              placeholder={{i18n "points_mall.admin.score_events.points"}}
              required={{true}}
              {{on "input" this.updatePoints}}
              class="score-event-form-input"
              style="
                padding: 10px 12px;
                border: 1px solid var(--primary-low);
                border-radius: 4px;
                font-size: 14px;
                background: var(--secondary);
                color: var(--primary);
                transition: border-color 0.2s;
                max-width: 200px;
              "
            />
            <small
              style="
                color: var(--primary-medium);
                font-size: 12px;
                margin-top: -4px;
              "
            >
              {{i18n "points_mall.admin.score_events.points_hint"}}
            </small>
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
            {{i18n "points_mall.admin.score_events.description"}}
            <textarea
              value={{this.description}}
              placeholder={{i18n "points_mall.admin.score_events.description"}}
              {{on "input" this.updateDescription}}
              rows="4"
              class="score-event-form-input"
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
            @label="points_mall.admin.score_events.cancel"
            @action={{this.cancel}}
            @disabled={{this.loading}}
            class="btn-default"
          />
          <DButton
            @label="points_mall.admin.score_events.save"
            @action={{this.submit}}
            @disabled={{this.loading}}
            class="btn-primary"
          />
        </div>
      </div>
    </div>
  </template>
}
