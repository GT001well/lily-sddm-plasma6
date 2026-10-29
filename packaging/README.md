# 发行版打包

项目按四个发行版家族维护打包元数据。运行时代码和安装目录保持一致，发行版
差异只存在于依赖包名和打包格式。

> 当前仅在 Arch 系、Plasma 6、Qt 6.12、SDDM 0.21 环境完成实际构建和测试。
> 以下 Debian、Fedora 和 openSUSE 元数据尚未在对应发行版中完成构建、
> 安装或真实 SDDM 登录验证。

| 家族 | 覆盖示例 | 打包文件 |
| --- | --- | --- |
| Arch | Arch Linux、Manjaro、EndeavourOS、CachyOS | 根目录 `PKGBUILD` |
| Debian | Debian、Ubuntu、KDE neon | `debian/` |
| Fedora | Fedora KDE、RHEL 系衍生版 | `packaging/rpm/lily-sddm-plasma6.spec` |
| openSUSE | openSUSE Tumbleweed、Slowroll | 同一 RPM spec 的 SUSE 条件分支 |

## Arch

```bash
make check
makepkg -f
sudo pacman -U lily-sddm-plasma6-*.pkg.tar.zst
```

## Debian / Ubuntu / KDE neon

安装构建依赖后，在项目根目录运行：

```bash
sudo apt install debhelper dpkg-dev make
dpkg-buildpackage -us -uc -b
sudo apt install ../lily-sddm-plasma6_*.deb
```

依赖名称以目标发行版仓库为准。该包要求 Plasma 6、SDDM 和
`qml6-module-qtquick-effects`。

## Fedora / openSUSE

先生成 RPM 使用的源码归档，再在对应发行版中构建：

```bash
make dist
rpmbuild -ba packaging/rpm/lily-sddm-plasma6.spec \
    --define "_sourcedir $PWD/dist"
```

Fedora 需要 `qt6-qtdeclarative-devel`、`qt6-qtdeclarative` 和 `qt6-qtsvg`；
openSUSE 使用 spec 中列出的 `qt6-declarative-devel`、`libQt6Quick6`、
`libQt6QuickEffects6` 和 `libQt6Svg6`。

## 检查

`make check` 会验证四套元数据的版本一致、共享安装树完整，以及关键依赖存在。
在 Arch 以外的系统构建时，还应使用对应的 `lintian`、`rpmlint` 或发行版构建
服务检查依赖名称和包策略。

## 素材授权

代码使用 `GPL-3.0-or-later`。壁纸与图标均由项目自行生成，随 GPL 一同分发。
