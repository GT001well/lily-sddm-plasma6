# Lily SDDM

[English](README.en.md)

这是一个我自用的 SDDM 主题，为 Plasma 6 兼容设计。
主题主体色可以根据当前壁纸自动设定，让登录界面与背景保持协调。

## 预览

![Lily SDDM 主题预览](docs/preview.png)

## 目录

- [预览](#预览)
- [项目结构](#项目结构)
- [安装方法](#安装方法)
- [更换壁纸](#更换壁纸)
- [兼容性与依赖](#兼容性与依赖)
- [许可证](#许可证)

## 项目结构

```text
Main.qml         主题界面和登录逻辑
metadata.desktop SDDM 主题元数据
theme.conf       颜色、字体和资源路径
PKGBUILD         Arch 打包脚本
debian/          Debian、Ubuntu、KDE neon 打包元数据
packaging/       Fedora、openSUSE RPM 元数据及发行版说明
assets/          生成壁纸、预览图和 SVG 图标
prototype/       HTML 布局原型
NOTE/            设计及维护文档
docs/            预览截图
scripts/         检查和预览脚本
LICENSE          GPL-3.0-or-later 许可证正文
```

## 安装方法

支持四个主流发行版家族：

- Arch、Manjaro、EndeavourOS：使用根目录 `PKGBUILD`。
- Debian、Ubuntu、KDE neon：使用 `debian/` 构建 DEB。
- Fedora：使用 `packaging/rpm/lily-sddm-plasma6.spec` 构建 RPM。
- openSUSE：使用同一 RPM spec 的 SUSE 条件分支。

> 当前仅在 Arch 系、Plasma 6、Qt 6.12、SDDM 0.21 环境完成实际构建和测试。
> Debian、Fedora、openSUSE 已提供打包元数据，但仍需在对应发行版中验证依赖
> 名称、安装过程和 SDDM 登录。

### Arch 系

```bash
make check
makepkg -si
```

也可以只构建包后手动安装：

```bash
makepkg -f
sudo pacman -U lily-sddm-plasma6-*-any.pkg.tar.zst
```

### Debian、Ubuntu、KDE neon

```bash
sudo apt install debhelper dpkg-dev make
dpkg-buildpackage -us -uc -b
sudo apt install ../lily-sddm-plasma6_0.2.2_all.deb
```

该方式要求目标发行版已提供 Plasma 6 和 Qt 6 SDDM。旧版 Plasma 5 系统不适用。

### Fedora

```bash
sudo dnf install rpm-build make qt6-qtdeclarative-devel
make dist
rpmbuild -ba packaging/rpm/lily-sddm-plasma6.spec \
    --define "_sourcedir $PWD/dist"
sudo dnf install ~/rpmbuild/RPMS/noarch/lily-sddm-plasma6-0.2.2-*.rpm
```

### openSUSE

```bash
sudo zypper install rpm-build make qt6-declarative-devel
make dist
rpmbuild -ba packaging/rpm/lily-sddm-plasma6.spec \
    --define "_sourcedir $PWD/dist"
sudo zypper install ~/rpmbuild/RPMS/noarch/lily-sddm-plasma6-0.2.2-*.rpm
```

完整的打包依赖、检查和源码归档说明见
[packaging/README.md](packaging/README.md)。
安装后在 Plasma 的“登录屏幕（SDDM）”中选择 Lily 主题。
主题预览来自包内 `assets/preview.png`。

## 更换壁纸

在 Plasma 系统设置的“登录屏幕（SDDM）”中选择当前主题和背景图片。
`sddm-kcm` 会把图片复制到主题目录，并写入 `theme.conf.user`。

左侧模糊和自动取色会在下次 greeter 启动时生效。

仓库内的默认壁纸由 `scripts/generate-wallpaper.py` 使用 Pillow 确定性生成。
安装 Pillow 后可运行 `make wallpaper` 重新生成。

## 兼容性与依赖

测试环境：

- SDDM 0.21.0-7
- Qt 6.12.0
- Plasma 6.8.2
- Greeter：`/usr/bin/sddm-greeter-qt6`

运行时还需要 Qt Quick Effects QML 模块和 Qt SVG 图片插件。各发行版包已分别
声明对应依赖。

未使用 Kirigami、PlasmaComponents、Breeze Components、Qt Quick Controls 或
`Qt5Compat.GraphicalEffects`。左侧模糊由 `MultiEffect` 在运行时生成。

壁纸选择后，greeter 会采样一次 `64×36` 缩略图，生成强调色、玻璃色调，
并据此派生输入框、功能键、会话控件和弹窗的低饱和深色表面及边框。文字、
错误色和主按钮文字保持固定，以维持对比度。`autoColors=false` 可关闭全部自动
取色；只关闭控件表面取色可设置 `autoSurfaceColors=false`。

`make check` 会验证四套打包元数据、共享安装树和许可证；安装 PySide6 时还会
额外验证 720p、1440p、4K、超宽屏和竖屏布局。
`make render-preview` 使用可选的 PySide6 和 ImageMagick 同步生成完整预览及
KCM 轻量预览，不参与 greeter 运行。

## 许可证

项目代码采用 `GPL-3.0-or-later`。壁纸与图标均由项目自行生成，随 GPL
一同分发。许可证正文见
`LICENSE`，安装包会将其放置到 `/usr/share/licenses/lily-sddm-plasma6/`。
