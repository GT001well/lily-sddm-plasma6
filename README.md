# Lily SDDM

[English](README.en.md)

这是一个我自用的 SDDM 主题，为 Plasma 6 兼容设计。
主题主体色可以根据当前壁纸自动设定，让登录界面与背景保持协调。

Plasma 6.7.5 升级到 6.8 后，之前配置的 SDDM 主题失效，登录界面回退到最初始
的 SDDM 界面。因此，我根据自用需求重新建立并维护了此主题。

## 预览

![Lily SDDM 主题预览](docs/preview.png)

## 目录

- [预览](#预览)
- [常用命令](#常用命令)
- [安装方法](#安装方法)
- [兼容性与依赖](#兼容性与依赖)
- [许可证](#许可证)

## 常用命令

运行 `make` 或 `make help` 可以查看全部入口：

| 命令 | 用途 |
| --- | --- |
| `make check` | 检查主题、原型和多分辨率布局 |
| `make check-layout` | 只运行多分辨率布局检查 |
| `make preview` | 使用真实 SDDM Qt 6 greeter 预览 |
| `make prototype` | 打开 HTML 布局原型 |
| `make render-preview` | 更新完整预览和 KCM 轻量预览 |
| `make install` | 安装主题；支持 `PREFIX` 和 `DESTDIR` |

## 安装方法

项目不维护各发行版的系统包元数据，直接使用源码安装。目标系统需已提供
Plasma 6、Qt 6 SDDM、Qt Quick Effects QML 模块和 Qt SVG 图片插件。如需系统
软件包，可按所用发行版的打包规则自行封装。

当前仅在 Arch 系、Plasma 6、Qt 6.12、SDDM 0.21 环境完成实际测试。

安装前先运行检查，确认当前环境可用：

```bash
make check
```

直接安装到系统目录：

```bash
sudo make install
```

如需先暂存安装结果：

```bash
make install DESTDIR="$PWD/stage" PREFIX=/usr
```

安装后在 Plasma 的“登录屏幕（SDDM）”中选择 Lily 主题。
主题预览来自安装后的 `assets/preview.png`。

## 兼容性与依赖

测试环境：

- SDDM 0.21.0-7
- Qt 6.12.0
- Plasma 6.8.2
- Greeter：`/usr/bin/sddm-greeter-qt6`

运行时还需要 Qt Quick Effects QML 模块和 Qt SVG 图片插件。请通过目标发行版
的软件源安装对应组件。

未使用 Kirigami、PlasmaComponents、Breeze Components、Qt Quick Controls 或
`Qt5Compat.GraphicalEffects`。左侧模糊由 `MultiEffect` 在运行时生成。

壁纸选择后，greeter 启动时会采样一次壁纸，自动生成强调色、玻璃色调以及
控件和弹窗的低饱和深色表面。`autoColors=false` 可关闭全部自动取色；只关闭
控件表面取色可设置 `autoSurfaceColors=false`。具体取色流程见
[NOTE/DEVELOPMENT.md](NOTE/DEVELOPMENT.md)。

检查依赖或兼容性时，先运行 `make check`。它验证 QML 导入、元数据、素材和
原型；安装 PySide6 时还会验证 720p、1440p、4K、超宽屏和竖屏布局。
`make preview` 使用真实 greeter 验证显示和交互。`make render-preview` 只用于
使用可选的 PySide6 和 ImageMagick 更新预览图，不能替代真实 greeter 验证。

## 许可证

项目代码与图标采用 `GPL-3.0-or-later`。默认壁纸为 Breeze Next（Hanabi），
作者 Krystian Zajdel，许可 CC-BY-SA-4.0。GPL 许可证正文见 `LICENSE`，
`make install` 会将其放置到 `/usr/share/licenses/lily-sddm-plasma6/`。
