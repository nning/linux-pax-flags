# Contributors:
#   henning mueller <henning@orgizm.net>

pkgname=linux-pax-flags
pkgdesc='Deactivates PaX flags for several binaries to work with "linux-pax"'
pkgver=1.0.24
pkgrel=1
arch=(any)
url='https://aur.archlinux.org/packages.php?ID=55491'
license=(GPL2)
depends=(bash paxctl)
source=($pkgname)
sha256sums=(b98e8b9aea7079a77a0e738b60cbf12e96bbdca051ee778f6d418e4b6b97784f)

build() {
  return 0
}

package() {
  install -D -m755 $srcdir/$pkgname $pkgdir/usr/bin/$pkgname
}
