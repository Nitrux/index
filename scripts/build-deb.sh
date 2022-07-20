#! /bin/bash

set -x

### Update sources

wget -qO /etc/apt/sources.list.d/neon-user-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.neon.user

wget -qO /etc/apt/sources.list.d/nitrux-main-compat-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux

wget -qO /etc/apt/sources.list.d/nitrux-testing-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux.testing

DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
	55751E5D > /dev/null

curl -L https://packagecloud.io/nitrux/repo/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/compat/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/testing/gpgkey | apt-key add -;

DEBIAN_FRONTEND=noninteractive apt -qq update

### Install Package Build Dependencies #2

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	mauikit-git \
	mauikit-accounts-git \
	mauikit-filebrowsing-git

### Download Source

git clone --depth 1 --branch $INDEX_BRANCH https://invent.kde.org/maui/index-fm.git

rm -rf index-fm/{.vscode,android_files,macos_files,windows_files,ios_files,screenshots,LICENSES,README.md}

#### Remove accentcolor property

sed -i '27d' index-fm/src/main.qml

### Compile Source

mkdir -p build && cd build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ../index-fm/

make -j$(nproc)

### Run checkinstall and Build Debian Package

>> description-pak printf "%s\n" \
	'MauiKit File Manager.' \
	'' \
	'Index is a file manager that works on desktops, Android and Plasma Mobile.' \
	'' \
	'Index lets you browse your system files and applications and preview' \
	'your music, text, image and video files and share them with external applications' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=index-git \
	--pkgversion=$PACKAGE_VERSION \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=utils \
	--pkgsource=index-fm \
	--pakdir=. \
	--maintainer=uri_herrera@nxos.org \
	--provides=index \
	--requires="libc6,libkf5archive5,libkf5configcore5,libkf5coreaddons5,libkf5i18n5,libkf5kiocore5,libkf5service5,mauikit-git \(\>= 2.1.2+git+1\),mauikit-filebrowsing-git \(\>= 2.1.2+git+1\),libqt5core5a,libqt5gui5,libqt5qml5,libqt5widgets5,libstdc++6,qml-module-qt-labs-platform" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
