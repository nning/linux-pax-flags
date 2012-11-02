# Contributors:
#   henning mueller <henning@orgizm.net>

pkgname=linux-pax-flags
pkgdesc='Deactivates PaX flags for several binaries to work with "linux-pax"'
pkgver=1.0.24
pkgrel=2
arch=(any)
url='https://aur.archlinux.org/packages.php?ID=55491'
license=(GPL2)
depends=(bash paxctl)
source=($pkgname)
sha256sums=(71e9c75fec61e078b59dcbc07c3ff450b12359657f888609b89fa2585ec58de6)

build() {
  return 0
}

package() {
  install -D -m755 $srcdir/$pkgname $pkgdir/usr/bin/$pkgname
}
