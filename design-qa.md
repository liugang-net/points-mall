# 积分商城设计 QA

- source visual truth path: `/Volumes/BaiduNetdiskDownload/0712定稿-论坛新源文件/积分商城_0708-1.png`
- implementation screenshot path: `/tmp/ibomy-points-mall-mobile-final.png`
- combined comparison evidence: `/tmp/ibomy-points-mall-comparison.png`
- viewport: `393 × 852`
- state: 已登录、商品列表正常加载、兑换按钮默认态与 hover 态

## Full-view comparison evidence

参考稿按 1440px 等比缩放到 393px 后与实现并排比较。头部、积分横幅、首张商品卡的横向边距、垂直顺序、粉色背景、黑色描边、黄色兑换按钮和整体信息层级一致。

## Focused region comparison evidence

- 积分区：指定像素字体已加载，数字使用横幅容器相对定位（横向 52%、纵向 68%）和 `cqi` 响应式字号，不再依赖固定像素偏移；393px 下字号约 38.2px，且未与“我的积分”重叠。
- 商品卡：实现使用接口返回的真实商品图、名称、积分和库存；参考稿中的灰色图片块和占位文案仅作为内容占位，因此不作为视觉偏差。
- 兑换按钮：hover 前后位置、宽高、2px 边框和斜切 transform 的实测值一致；仅允许颜色反馈。

## Findings

- 无 P0/P1/P2 问题。
- 卡片已复用项目 `--tile-background` CDN 暗纹，移动端纹理尺寸为 10px。
- 开发环境右上角的渲染耗时浮层不属于产品 UI。

## Comparison history

1. 首轮发现积分数字与横幅标题纵向距离不足，且商品卡 hover 会整体上浮。
2. 将积分数字改为横幅容器百分比锚点和响应式字号，移除卡片位移；锁定按钮 hover/focus/active 的高度、边框、阴影与 transform。
3. 为卡片加入项目已有的 tile CDN 暗纹，复测按钮 hover 前后 `x/y/width/height/border/transform` 均一致，控制台无 error 或 warn。

## Interaction checks

- 页面身份：`http://127.0.0.1:4200/points-mall/products`，标题 `Discourse`。
- 页面非空：商品列表、积分数与两个兑换按钮均已渲染。
- 框架错误浮层：未发现。
- 控制台：0 error，0 warn。
- hover：兑换按钮无位移、无尺寸或边框变化。

final result: passed
