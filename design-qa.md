# Points Mall Intro Design QA

## Evidence

- source visual truth path: `/var/folders/_z/0zf4rjl956z5wtj8_t359x3h0000gp/T/browser-use/assets/fde0c1e1-84fd-48f4-ae57-6628481e0c16/f7357a8de0bb39a2.png`
- source visual: 蓝湖「积分商城-0804 · 版本1」原始画板
- implementation URL: `http://127.0.0.1:4200/points-mall`
- implementation screenshot path: `/tmp/points-mall-intro-implementation-final.jpg`
- desktop community screenshot path: `/tmp/points-mall-community-desktop-final.png`
- focused mobile community source: `/var/folders/_z/0zf4rjl956z5wtj8_t359x3h0000gp/T/codex-clipboard-26179622-c2fe-49b9-8d69-8903adb95298.png`（`610 × 1105`）
- focused mobile community implementation: `/tmp/points-mall-community-mobile-final.png`（480px 移动端视口）
- viewport: `480 × 1000` CSS px
- desktop viewport: `1440 × 1000` CSS px；站点容器内页面实测宽度 `1088.5625px`
- state: `/points-mall` 默认、未登录、页面顶部；使用现有 Discourse Header
- source pixels: `1440 × 10000`，设计密度 `@3x`
- normalized source: `/tmp/points-mall-intro-source-480.png`，`480 × 3333`
- implementation pixels: `465 × 3275`（15px 为浏览器滚动条占位），归一化到 `/tmp/points-mall-intro-implementation-final-480.jpg`，`480 × 3381`
- full-view comparison evidence: `/tmp/points-mall-intro-comparison-final.png`
- focused hero/shop evidence: `/tmp/points-mall-intro-focus-final-hero-shop.png`
- focused community evidence: `/tmp/points-mall-intro-focus-final-community.png`
- focused FAQ evidence: `/tmp/points-mall-intro-focus-final-faq.png`

## Findings

- 无 P0、P1 或 P2 问题。
- 字体与排版：`Bomi积分`、`积分商店`、`社区奖励`、`常见问题` 均实际加载 `LogoSC-UnboundedSans.woff2`；正文、强调数字、规则文字和 FAQ 层级与设计稿一致。最终 FAQ 和社区正文换行已按 480px 画板校准。
- 间距与布局节奏：黄色首屏、积分卡片、三角过渡、积分商店、交易横幅、社区奖励和 FAQ 的顺序及比例匹配。PC 版放宽到与商品页相同的站点内容容器，实测页面宽度 `1088.5625px`；社区卡片底色保持宽版，文字内容避开左侧角色切图，无遮挡。
- 颜色与视觉标记：黄色、品红、青色、黑色描边和 10px 暗纹均与设计稿对应；三块社区奖励卡片使用 `rgba(246, 246, 246, 0.9)`，等效于 `#F6F6F6` + `opacity: 0.9`，且不降低内部文字和链接的清晰度。
- 图片质量与素材一致性：8 张可见插画与箭头、问号图标均使用用户提供并上传 CDN 的原始蓝湖切图；未使用占位图或代码绘制替代素材。
- 文案内容：页面正文以蓝湖为准，FAQ 用 DOCX 补齐；产品评测、创意工坊、求助问答链接指向现有论坛分类。
- 可接受差异：设计稿中的状态栏和粉色页面标题栏没有重复实现，按用户要求使用现有 Discourse Header。

## Comparison History

### Iteration 1

- earlier finding: `[P1]` 初次运行因不兼容的 `LinkTo` 模块导入而显示插件错误页。
- fix: 改为 Discourse 可接管的标准站内链接 `/points-mall/products`。
- post-fix evidence: 页面完整渲染，交易入口导航到 `/points-mall/products`。

### Iteration 2

- earlier finding: `[P2]` 首轮同宽对比中，社区正文与 FAQ 正文字号偏小，FAQ 换行密度高于设计稿。
- fix: 社区正文校准为 `13.5px`，FAQ 正文校准为 `13px`、问题标题为 `15px`，并保持设计稿行高。
- post-fix evidence: `/tmp/points-mall-intro-comparison-final.png`；归一化页面高度为 `3381px`，接近源设计 `3333px`，关键文案换行与层级一致。

### Iteration 3

- earlier finding: `[P2]` PC 放宽后，社区角色切图覆盖了第二段正文开头。
- fix: 保持半透明卡片向左延伸的设计结构，将三段卡片的文字内容区左内边距调整为 `23%`，让正文从角色右侧开始。
- post-fix evidence: `/tmp/points-mall-community-desktop-final.png`；三段正文与角色边界清晰，卡片宽度和垂直节奏保持不变。

### Iteration 4

- earlier finding: `[P2]` 三块社区奖励卡片的底色透明度与设计标注不一致。
- fix: 卡片背景改为 `rgba(246, 246, 246, 0.9)`，在保持内容完全不透明的同时实现标注中的 90% 背景透明度。
- post-fix evidence: `/tmp/points-mall-community-desktop-final.png`；浏览器计算样式确认为 `rgba(246, 246, 246, 0.9)`。

### Iteration 5

- earlier finding: `[P2]` 社区角色切图位于卡片内容上层，与设计稿图层关系相反。
- fix: 将角色层级调整为 `z-index: 1`，三块半透明卡片及内容调整为 `z-index: 2`。
- post-fix evidence: `/tmp/points-mall-community-layer-final.png`；角色透过 90% 背景显示在底层，文字与链接完整位于上层。

### Iteration 6

- earlier finding: `[P2]` 移动端角色以卡片容器定位，导致角色起点偏低；卡片内容为避让角色被错误右移，三张卡片的高度与纵向位置也和蓝湖局部截图不一致。
- fix: 新增“奖励插画＋角色＋卡片”的统一定位容器；角色按原始 `456 × 1444` 比例渲染并从奖励插画左侧开始；卡片恢复全宽内容区。按 `610px → 480px` 比例换算，将三张卡片起点校准到约 `305 / 439 / 573px`，卡片高度校准为 `116px`，间距为 `18px`；链接图标放大到 `18px`。
- post-fix evidence: `/tmp/points-mall-community-mobile-final.png`；卡片左边缘、宽度、三段起点、角色贯穿范围及 FAQ 衔接均与用户提供的蓝湖局部截图一致。

## Interaction And Runtime Checks

- “前往交易”已实际点击验证，成功进入 `/points-mall/products`。
- 产品评测、创意工坊、求助问答链接分别为 `/c/6/6`、`/c/5/5`、`/c/7/7`。
- 指定标题字体的计算样式已验证为 `"Ibomy Unbounded Sans"`。
- 所有 CDN 切图与暗纹资源均返回 HTTP 200。
- 浏览器控制台错误：0。
- ESLint：通过。
- Ember Template Lint：通过。
- Prettier：通过。
- `git diff --check`：通过。
- Stylelint 全文件仍报告 5 个本次修改前已存在的问题；新增的积分介绍页样式没有新增 Stylelint 问题。

## Follow-up Polish

- `[P3]` 不同系统中文字体的字宽可能造成极小的 FAQ 换行差异，可在生产字体确定后再做逐行微调。

final result: passed
