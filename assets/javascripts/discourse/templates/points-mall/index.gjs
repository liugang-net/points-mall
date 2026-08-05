import { concat } from "@ember/helper";

const ASSET_ROOT = "https://cdn.ibomy.com/forum/points-mall";

export default <template>
    <main class="points-mall-intro">
      <section class="points-mall-intro__hero">
        <div class="points-mall-intro__hero-content">
          <h1>Bomi积分</h1>
          <p class="points-mall-intro__hero-copy">
            在 啵咪旗下店铺上购物或向 Bomi 社区作出贡献，<br />即可获得积分。
          </p>
          <img
            class="points-mall-intro__hero-characters"
            src={{concat ASSET_ROOT "/points-mall-hero-characters.png"}}
            alt="BOMI角色组合"
          />
          <p class="points-mall-intro__hero-note">
            用您的积分兑换奖品，或向社区成员发出奖励、悬赏价值信息。
          </p>
          <div class="points-mall-intro__earn-card">
            <strong>
              每消费 <em>￥10<small>.00</small></em> 即可获取
              <em>1</em> 积分。
            </strong>
            <span>购买任何产品、定制服务、配件、或社区内物品，<br />都可获得积分。</span>
          </div>
        </div>
      </section>

      <div class="points-mall-intro__texture">
        <section class="points-mall-intro__section points-mall-intro__shop">
          <h2>积分商店</h2>
          <p class="points-mall-intro__section-lead">
            您可以在积分商店中<br />
            找到用以个性化自己社区状态的各色物品，<br />
            或将您的积分兑换为对应奖品。
          </p>

          <ul class="points-mall-intro__rules">
            <li>
              <img src={{concat ASSET_ROOT "/points-mall-rule-permanent.png"}} alt="永久保留" />
              <strong>获得的特殊头像、背景、徽章和系统物品皆可<br />永久保留。</strong>
            </li>
            <li>
              <img src={{concat ASSET_ROOT "/points-mall-rule-always-open.png"}} alt="全年开放" />
              <strong>积分商店将会常驻于此，全年开放！</strong>
            </li>
            <li>
              <img src={{concat ASSET_ROOT "/points-mall-rule-non-tradable.png"}} alt="不可交易" />
              <strong>来自积分商店的物品不可出售或交易。</strong>
            </li>
          </ul>

          <a href="/points-mall/products" class="points-mall-intro__trade-link">
            <img
              class="points-mall-intro__trade-banner"
              src={{concat ASSET_ROOT "/points-mall-trade-banner.png"}}
              alt="积分兑换，前往积分商店"
            />
            <img
              class="points-mall-intro__trade-button"
              src={{concat ASSET_ROOT "/points-mall-trade-button.png"}}
              alt="前往交易"
            />
          </a>
        </section>

        <section class="points-mall-intro__section points-mall-intro__community">
          <h2>社区奖励</h2>
          <p class="points-mall-intro__section-lead">
            使用您的积分发放奖励，<br />
            让BOMI社区上的评测、讨论帖和玩家生成内容<br />
            更引人注目。奖励会向所有玩家显示。
          </p>

          <div class="points-mall-intro__community-showcase">
            <img
              class="points-mall-intro__community-rewards"
              src={{concat ASSET_ROOT "/points-mall-community-rewards.png"}}
              alt="向社区优质内容发放积分奖励"
            />
            <img
              class="points-mall-intro__community-character"
              src={{concat ASSET_ROOT "/points-mall-community-character.png"}}
              alt="BOMI社区角色"
            />

            <div class="points-mall-intro__community-stories">
              <article>
              <p>
                有时候您阅读了一则有价值、独一无二或是行文极佳的评测，让您不禁想和撰写者握手致意。现在，您可以给他们发放奖励，表彰他们的努力。
              </p>
              <a href="/c/6/6">
                <img
                  class="points-mall-intro__link-icon"
                  src={{concat ASSET_ROOT "/points-mall-link-arrow.svg"}}
                  alt=""
                />
                浏览或发布评测
              </a>
              </article>
              <article>
              <p>
                有些玩家创作的内容充满灵感，让人产生“想亲自体验”的冲动。现在您也可以通过发放积分，表彰这些来自创意工坊的想法、思路或指南。
              </p>
              <a href="/c/5/5">
                <img
                  class="points-mall-intro__link-icon"
                  src={{concat ASSET_ROOT "/points-mall-link-arrow.svg"}}
                  alt=""
                />
                访问创意工坊
              </a>
              </article>
              <article>
              <p>
                看到其他用户的创意获得认可，是否也曾心生向往？现在，你也可以通过参与社区互动，获取积分奖励，支持喜欢的内容，也让你的内容获得更多关注。
              </p>
              <a href="/c/7/7">
                <img
                  class="points-mall-intro__link-icon"
                  src={{concat ASSET_ROOT "/points-mall-link-arrow.svg"}}
                  alt=""
                />
                访问求助问答
              </a>
              </article>
            </div>
          </div>
        </section>

        <section class="points-mall-intro__faq">
          <h2>
            常见问题
            <img
              src={{concat ASSET_ROOT "/points-mall-faq-question.svg"}}
              alt=""
              aria-hidden="true"
            />
          </h2>

          <article>
            <h3>如何获取 BOMI 积分？</h3>
            <p>
              在 BOMI 社区消费即可获得积分奖励。<br />
              每消费 ￥10 元即可获得 1 积分，购买产品、定制服务、配件以及社区内开放购买的物品，均可累计积分。<br />
              此外，参与社区互动、发布优质内容、参与官方活动等，也有机会获得额外积分奖励。
            </p>
          </article>

          <article>
            <h3>BOMI 积分会过期吗？</h3>
            <p>
              不会。<br />
              积分系统将长期开放，您获得的积分可持续用于社区内的互动奖励与权益兑换。
            </p>
          </article>

          <article>
            <h3>积分可以兑换什么？</h3>
            <p>
              积分可用于兑换社区权益，包括发放内容奖励、实物积分兑换、获取专属福利等。<br />
              未来我们也会持续扩展积分用途，为用户提供更多社区互动体验。
            </p>
          </article>

          <article>
            <h3>我获得的奖励或兑换物品可以转让吗？</h3>
            <p>
              不可以。<br />
              通过积分兑换或获得的社区权益均与您的 BOMI 账号绑定，仅限本人使用，无法转移至其他账号。
            </p>
          </article>

          <article>
            <h3>什么是社区奖励？</h3>
            <p>
              社区奖励是 BOMI 鼓励优质内容创作的一种方式。<br />
              当您发现一篇有价值的评测、一份优秀的创意分享，或一篇实用的使用指南时，可以使用积分为内容作者送上奖励，让优秀作品获得更多关注。
            </p>
          </article>

          <article>
            <h3>社区奖励会影响内容排名吗？</h3>
            <p>
              不会。<br />
              社区内容通常会根据发布时间、互动数据以及社区规则进行展示排序。<br />
              获得奖励数量不会直接改变内容排名，但优质内容更容易获得用户关注，并形成更多互动。
            </p>
          </article>

          <article>
            <h3>哪些内容可以获得社区奖励？</h3>
            <p>
              BOMI 社区中的多种优质内容均可获得奖励，包括：<br />
              产品体验评测、使用技巧分享、创意设计方案、图文视频原创内容等。<br />
              每一份认真创作的内容，都值得被更多用户发现。
            </p>
          </article>

          <article>
            <h3>如果我的积分不足，还可以发放奖励吗？</h3>
            <p>
              不能。<br />
              发放社区奖励需要消耗对应积分，请确保您的积分余额充足。
            </p>
          </article>

          <article>
            <h3>为什么我的内容没有获得奖励？</h3>
            <p>
              社区奖励由用户自主选择，并非所有内容都会自动获得奖励。<br />
              持续分享高质量内容、真实体验与独特创意，更容易获得其他用户的认可。
            </p>
          </article>
        </section>
      </div>
    </main>
  </template>;
