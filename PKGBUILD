# Maintainer: Lily <gt001well@users.noreply.github.com>
pkgname=lily-sddm-plasma6
pkgver=0.2.3
pkgrel=1
pkgdesc='Frosted-glass SDDM theme for Plasma 6 and Qt 6'
url='https://github.com/gt001well/Lily-sddm-plasma6'
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
sha256sums=('8f97acc38fb2d40c300b01a17d40f3662a67d0b02158be0d13fc934d4f6f4ab1')

check() {
    make -C "$srcdir/$pkgname-$pkgver" check
}

package() {
    make -C "$srcdir/$pkgname-$pkgver" install DESTDIR="$pkgdir" PREFIX=/usr
}
