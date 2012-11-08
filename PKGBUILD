# Contributors:
#   henning mueller <henning@orgizm.net>

pkgname=linux-pax-flags
pkgdesc='Deactivates PaX flags for several binaries to work with PaX enabled kernels.'
pkgver=1.0.26
pkgrel=1
arch=(any)
url='https://aur.archlinux.org/packages.php?ID=55491'
license=(GPL2)
depends=(bash paxctl)
source=($pkgname)
sha256sums=(928491423d3f99b9d517f4047cc903a1b6a641b7500cbf54361d5d9f998ee146)

build() {
  return 0
}

package() {
  install -D -m755 $srcdir/$pkgname $pkgdir/usr/bin/$pkgname
}
