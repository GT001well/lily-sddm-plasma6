# 开发维护说明

## 兼容性边界

QML 导入、属性类型或资源路径错误会导致 SDDM greeter 回退到内嵌主题。以下
约束必须持续维护：

- `Main.qml` 只导入 `QtQuick`、`QtQuick.Effects` 和 `SddmComponents 2.0`。
- 每个 `font.pixelSize` 都使用整数。
- 相对图片路径通过 `Qt.resolvedUrl()` 解析。
- 运行时提供 Qt Quick Effects QML 模块和 Qt SVG 图片插件。
- 会话选择使用 `Repeater` 配合 `sessionModel`，显示角色名为 `name`。
- `metadata.desktop` 声明 Theme API 2.0、Qt 6、GPL 许可证、预览图、
  `Main.qml` 和 `theme.conf`。

## 源码职责

- `prototype/` 是视觉设计构思，`Main.qml` 是最终 SDDM 界面和登录实现。
- `theme.conf` 保存颜色、字体和默认资源路径，`theme.conf.user` 可覆盖壁纸。
- `scripts/check-theme.sh` 和 `scripts/check-prototype.sh` 检查静态结构与素材。
- `scripts/check-layout.py` 验证 720p、1440p、4K、超宽屏和竖屏布局。

壁纸由 Plasma“登录屏幕（SDDM）”设置提供。greeter 启动时把壁纸缩小到
`64×36` 并采样一次，生成强调色、玻璃色调和控件表面；失败时回退到
`theme.conf`。文字、错误色和主按钮文字保持固定。

代码与图标使用 `GPL-3.0-or-later`。默认壁纸 Breeze Next（Hanabi）由
Krystian Zajdel 创作，使用 `CC-BY-SA-4.0`，署名和许可必须保留。

## 预览与检查

运行全部检查：

```bash
make check
```

使用真实 Qt 6 greeter 验证显示和交互：

```bash
make preview
```

`make render-preview` 使用可选的 PySide6 和 ImageMagick 更新完整预览及 KCM
轻量预览。它只验证布局，不验证真实 PAM、电源操作、多显示器或 GPU 模糊；
离屏软件渲染不能替代 `make preview`。

## 发布检查清单

1. 更新 `CHANGELOG.md`，需要发版时同步 `metadata.desktop` 中的版本号。
2. 运行 `make check` 和 `make render-preview`，确认预览同步更新。
3. 在目标分辨率和显示缩放下运行 `make preview`，检查布局与 GPU 模糊。
4. 验证单用户、多用户、免密码账户、错误密码、会话选择和回车登录。
5. 验证关机、重启、休眠、取消路径，并在 TTY 中完成受控 SDDM 测试。
6. 检查 KCM 预览、许可证、默认壁纸署名和 `git diff`，再创建 tag 与 Release。
