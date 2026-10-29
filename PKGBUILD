# Maintainer: Lily <gt001well@users.noreply.github.com>
pkgname=lily-sddm-plasma6
pkgver=0.2.2
pkgrel=1
pkgdesc='Frosted-glass SDDM theme for Plasma 6 and Qt 6'
arch=('any')
license=('GPL-3.0-or-later')
options=('!strip')
depends=('sddm' 'qt6-declarative>=6.5' 'qt6-svg')
optdepends=(
    'sddm-kcm: select the login wallpaper from Plasma settings'
    'noto-fonts-cjk: preferred login-screen font'
)
changelog=CHANGELOG.md

_pkgbuild_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source=()
sha256sums=()

check() {
    make -C "$_pkgbuild_dir" check
}

package() {
    make -C "$_pkgbuild_dir" install DESTDIR="$pkgdir" PREFIX=/usr
}
