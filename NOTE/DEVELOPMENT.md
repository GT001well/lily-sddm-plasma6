# 开发维护说明

## 兼容性边界

本主题有意采用保守实现。QML 导入错误或属性类型错误都会导致 SDDM greeter
回退到内嵌主题，因此以下约束必须持续维护：

- `Main.qml` 只导入 `QtQuick`、`QtQuick.Effects` 和 `SddmComponents 2.0`。
- 每个 `font.pixelSize` 的值都必须写成整数。
- 相对图片路径必须通过 `Qt.resolvedUrl()` 解析。
- 运行时必须提供 Qt Quick Effects QML 模块和 Qt SVG 图片插件。
- 会话选择使用 `Repeater` 配合 `sessionModel`，显示角色名为 `name`。
- `metadata.desktop` 必须声明 Theme API 2.0、Qt 6、GPL 许可证、预览图、
  `Main.qml` 和 `theme.conf`。

## 当前同步状态

- `prototype/` 是当前毛玻璃设计源，包含最新的头像、功能键、时间和菜单样式。
- 根目录 `Main.qml` 已同步当前视觉，直接使用 Qt Quick 基础类型实现交互，
  不照搬 HTML 表单结构。
- 左侧毛玻璃使用 `ShaderEffectSource` 和 `MultiEffect` 实时生成，纹理降采样
  到一半分辨率，只覆盖左侧区域，不做右侧渐隐。
- 系统头像由 `MultiEffect` 圆形遮罩裁切，不使用 Canvas。图片未加载、effects
  不可用或处于离屏预览模式时显示姓名首字母。
- 软件渲染时效果不可用，半透明色调层仍会保留。
- HTML 原型宽度为 `34rem`，QML 使用 `608px` 设计宽度；两者按各自画布和控件
  尺寸校准，不要求像素宽度相同。

壁纸通过 Plasma 的“登录屏幕（SDDM）”设置选择。`sddm-kcm` 会把图片复制到
主题目录，并用 `theme.conf.user` 覆盖 `background`。greeter 启动时会把壁纸
缩小到 `64×36` 并采样一次，生成强调色和玻璃色调，并从同一色相派生控件表面、
悬停、选中和弹窗的深色背景及边框；失败时使用 `theme.conf` 中的固定值。
文字色、错误色和主按钮文字保持固定，以保证可读性。`autoSurfaceColors=false`
可保留自动强调色，同时使用 `theme.conf` 中的固定控件颜色。

随包默认壁纸为 Breeze Next（Hanabi），作者 Krystian Zajdel，许可
CC-BY-SA-4.0。

`docs/preview.png` 保存完整尺寸预览；`assets/preview.png` 是打包进主题的轻量
KCM 预览图。若 KCM 显示“无可用预览”，确认 `metadata.desktop` 的 `Screenshot`
指向 `assets/preview.png`，并确认软件包实际包含该文件。

项目代码与图标使用 `GPL-3.0-or-later`；默认壁纸使用 CC-BY-SA-4.0，并保留
作者与许可署名。

## 动效维护

- 页面首次加载或刷新后，登录区域必须直接显示，不播放淡入、上浮或缩放。
- 菜单、对话框和密码显隐可以保留短时过渡，动画只用于解释用户触发的状态变化。
- 电源确认弹窗支持取消按钮、`Esc` 和点击外部关闭；只有明确点击“继续”才执行
  危险操作。
- HTML 原型中的新增动画必须复用 `styles.css` 中的时长和缓动 token，并在
  `prefers-reduced-motion` 下可被关闭。
- QML 只对用户主动触发的菜单、确认层和颜色状态使用动画，不在窗口首次呈现时
  播放整页入场动画。
- 修改菜单结构时，在 HTML 中保留 `aria-hidden="true"` 和 `inert` 初始状态，
  由脚本统一维护展开状态，避免脚本加载前出现不可交互但仍暴露给辅助技术的菜单。

## 预览机制

直接使用 Qt 6 SDDM greeter：

```bash
./scripts/preview.sh
```

`--test-mode` 会在不安装主题、不修改系统当前主题的情况下，为 QML 提供接近
真实 SDDM 的运行上下文。预览运行在当前桌面会话中，关闭窗口不会影响系统
SDDM 服务。

安装 PySide6 后，`make check` 会自动运行 `scripts/check-layout.py`，验证
720p、1440p、4K、超宽屏和竖屏下画布、登录区域、页脚与时钟的位置。

offscreen 运行只适合做基础启动测试。当前打包的 greeter 在 offscreen 模式下
不能稳定输出 QML 诊断，因此不能把它作为视觉和交互验证的唯一依据。

自动化工具无法接入桌面显示时，可以使用 Qt 的 VNC 平台启动同一个 greeter，
再抓取虚拟帧缓冲进行视觉检查。VNC 只用于开发验证，不是正式登录环境。

当开发环境无法访问桌面显示时，可使用以下命令在 offscreen 模式注入模拟用户、
会话和认证对象，同时更新 `docs/preview.png` 与 `assets/preview.png`：

```bash
make render-preview
```

该工具依赖可选的 PySide6 和 ImageMagick，只验证布局，不验证软件渲染下的模糊
效果、真实 PAM、电源操作或多显示器行为。offscreen 软件后端无法运行
`MultiEffect`，因此预览工具会渲染透明 UI 层，再用同一张壁纸合成左侧模糊背景；
实际 GPU 模糊仍须用 `make preview` 验证。

## 发布检查清单

1. 运行 `make check`。
2. 运行 `make render-preview`，确认两份预览已同步更新。
3. 运行 `make dist` 生成发行源码归档。
4. 构建并检查 Arch、Debian、Fedora 和 openSUSE 四套包。
5. 在目标分辨率和显示缩放下进行预览。
6. 验证单用户、多用户和免密码账户行为。
7. 验证密码错误、会话选择以及回车登录。
8. 验证关机、重启、休眠按钮在支持时是否正确显示。
9. 修改 SDDM 当前主题前，先在 TTY 中完成受控测试。
10. 同步 `CHANGELOG.md`、`PKGBUILD`、`metadata.desktop`、Debian changelog
    和 RPM spec 中的版本号。
11. 验证 KCM 预览、许可证元数据与正文，并确认默认壁纸署名完整。
12. 确认 `NOTE/DESIGN_SPEC.md`、`NOTE/DEVELOPMENT.md` 和
   `prototype/README.md` 与实际原型一致。

