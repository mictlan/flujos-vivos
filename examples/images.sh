#!/bin/sh -e

# Static variables
DISTRIBUTIONS="${DISTRIBUTIONS:-lenny}"
FLAVOURS="${FLAVOURS:-flujos}"
SOURCE="${SOURCE:-disable}"

MIRROR="${MIRROR:-http://localhost:9999/debian/}"
MIRROR_SECURITY="${MIRROR_SECURITY:-http://localhost:9999/security/}"

# Dynamic variables
#ARCHITECTURE="$(dpkg --print-architecture)"
ARCHITECTURE="i386"
DATE="$(date +%Y%m%d)"
VERSION="1.1"
#NAME="flujos-vivos-${VERSION}-${DISTRIBUTION}"
DEST="/home/kev/www/live/"

for DISTRIBUTION in ${DISTRIBUTIONS}
do
	rm -rf cache/stages*

	for FLAVOUR in ${FLAVOURS}
	do
		mkdir -p config

		if [ -e .stage ]
		then
			lh clean
		fi

		#rm -rf config
		rm -rf cache/packages*
		rm -rf cache/stages_rootfs

		case "${ARCHITECTURE}" in
			amd64)
				case "${FLAVOUR}" in
					gnome-desktop)
						mkdir -p config/chroot_local-hooks
						echo "apt-get remove --yes --purge openoffice.org-help-en-us" > config/chroot_local-hooks/package-removals
						echo "apt-get remove --yes --purge epiphany-browser epiphany-browser-data epiphany-extensions epiphany-gecko" >> config/chroot_local-hooks/package-removals
						echo "apt-get remove --yes --purge gnome-user-guide" >> config/chroot_local-hooks/package-removals

						INDICES="none"
						;;

					kde-desktop)
						INDICES="none"
						;;
				esac
				;;

			i386)
				case "${FLAVOUR}" in
					standard|rescue|lxde-desktop|xfce-desktop)
						INDICES="enabled"
						;;

					gnome-desktop|kde-desktop)
						KERNEL="-k 686"
						INDICES="none"
						;;
				esac
				;;
		esac

		if [ "${SOURCE}" = "enabled" ]
		then
			lh config -d ${DISTRIBUTION} -p ${FLAVOUR} --cache-stages "bootstrap rootfs" --apt-recommends disabled --binary-indices ${INDICES} --tasksel aptitude ${KERNEL} --source enabled --mirror-bootstrap ${MIRROR} --mirror-chroot ${MIRROR} --mirror-chroot-security ${MIRROR_SECURITY}
		else
			lh config -d ${DISTRIBUTION} -p ${FLAVOUR} --cache-stages "bootstrap rootfs" --apt-recommends disabled --binary-indices ${INDICES} --tasksel aptitude ${KERNEL} --source disabled --mirror-bootstrap ${MIRROR} --mirror-chroot ${MIRROR} --mirror-chroot-security ${MIRROR_SECURITY}
		fi

		if [ "${DISTRIBUTION}" = "sid" ]
		then
			echo 'deb http://live.debian.net/ sid/snapshots main' > config/chroot_sources/flujos-vivos_sid-snapshots.chroot
			echo 'deb http://live.debian.net/ sid/snapshots main' > config/chroot_sources/flujos-vivos_sid-snapshots.boot

			wget http://live.debian.net/debian/project/openpgp/archive-key.asc -O config/chroot_sources/flujos-vivos_sid-snapshots.chroot.gpg
			wget http://live.debian.net/debian/project/openpgp/archive-key.asc -O config/chroot_sources/flujos-vivos_sid-snapshots.binary.gpg

		fi

        lh config -b iso

		lh build 2>&1 | tee flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso.log

		mv binary.iso flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso
		mv binary.list flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso.list
		mv binary.packages flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso.packages
        md5sum flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso > flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso.md5sum
        cp flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.iso* ${DEST}/iso-cdrom/

		if [ "${SOURCE}" = "enabled" ]
		then
			mv source.tar.gz flujos-vivos-${VERSION}-${DISTRIBUTION}-source-${FLAVOUR}.tar.gz
			mv source.list flujos-vivos-${VERSION}-${DISTRIBUTION}-source-${FLAVOUR}.tar.gz.list
		fi

		lh clean --binary
		lh config -b usb-hdd
		lh binary 2>&1 | tee flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img.log

		mv binary.img flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img
		mv binary.list flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img.list
		mv binary.packages flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img.packages
        md5sum flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img > flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img.md5sum
        cp flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}.img* ${DEST}/usb-hdd/

		lh clean --binary
		lh config -b net
		lh binary 2>&1 | tee flujos-vivos-${VERSION}-${DISTRIBUTION}-i386-${FLAVOUR}-net.tar.gz.log

		mv binary-net.tar.gz flujos-vivos-${VERSION}-${DISTRIBUTION}-i386-${FLAVOUR}-net.tar.gz
		mv binary.list flujos-vivos-${VERSION}-${DISTRIBUTION}-i386-${FLAVOUR}-net.tar.gz.list
		mv binary.packages flujos-vivos-${VERSION}-${DISTRIBUTION}-i386-${FLAVOUR}-net.tar.gz.packages
        md5sum flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}-net.tar.gz > flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}-net.tar.gz.md5sum
        cp flujos-vivos-${VERSION}-${DISTRIBUTION}-${ARCHITECTURE}-${FLAVOUR}-net.tar.gz* ${DEST}/net/

		mv binary/*/filesystem.squashfs flujos-vivos-${VERSION}-${DISTRIBUTION}-i386-${FLAVOUR}.squashfs
        md5sum flujos-vivos-${VERSION}-${DISTRIBUTION}-i386-${FLAVOUR}.squashfs > flujos-vivos-${VERSION}-${DISTRIBUTION}-i386-${FLAVOUR}.squashfs.md5sum
        cp flujos-vivos-${VERSION}-${DISTRIBUTION}-i386-${FLAVOUR}.squashfs* ${DEST}/squashfs/
	done
done

rsync ${DEST}/ ${RDEST}
