# Maintainer: Lily <gt001well@users.noreply.github.com>
pkgname=lily-sddm-plasma6
pkgver=0.2.3
pkgrel=1
pkgdesc='Frosted-glass SDDM theme for Plasma 6 and Qt 6'
url='https://github.com/GT001well/lily-sddm-plasma6'
arch=('any')
license=('GPL-3.0-or-later' 'CC-BY-SA-4.0')
options=('!strip')
depends=('sddm' 'qt6-declarative>=6.5' 'qt6-svg')
makedepends=('ripgrep')
optdepends=(
    'sddm-kcm: select the login wallpaper from Plasma settings'
    'noto-fonts-cjk: preferred login-screen font'
)
changelog=CHANGELOG.md

source=("$pkgname-$pkgver.tar.gz::$url/releases/download/v$pkgver/$pkgname-$pkgver.tar.gz")
sha256sums=('84428910754c06e990d171f5af8f5fc9614522b90252c3d06f41e37cd4147110')

check() {
    make -C "$srcdir/$pkgname-$pkgver" check
}

package() {
    make -C "$srcdir/$pkgname-$pkgver" install DESTDIR="$pkgdir" PREFIX=/usr
}
