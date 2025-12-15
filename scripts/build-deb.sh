#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Download Source

git clone --depth 1 --branch "$INDEX_BRANCH" https://invent.kde.org/maui/index-fm.git

rm -rf index-fm/{.vscode,android_files,macos_files,windows_files,ios_files,screenshots,LICENSES,README.md}

if ! grep -Eq 'find_package\(Qt.*REQUIRED COMPONENTS.*Qml' index-fm/CMakeLists.txt; then
  sed -i '/find_package(Qt.*REQUIRED COMPONENTS/ s/Core/& Qml/' index-fm/CMakeLists.txt
fi

if grep -qE '^[[:space:]]*qt_policy\(SET QTP0004 NEW\)' index-fm/CMakeLists.txt; then
  sed -i '/^[[:space:]]*qt_policy(SET QTP0004 NEW)/c\
if(QT_VERSION VERSION_GREATER_EQUAL "6.8.0")\
  qt_policy(SET QTP0004 NEW)\
endif()' index-fm/CMakeLists.txt
fi


# -- Remove accentcolor property

sed -i '27d' index-fm/src/main.qml


# -- Compile Source

mkdir -p build && cd build

HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)

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
	-DCMAKE_INSTALL_LIBDIR="/usr/lib/${HOST_MULTIARCH}" \
	../index-fm/

make -j"$(nproc)"

make install


# -- Run checkinstall and Build Debian Package

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
	--pkgname=index \
	--pkgversion="$PACKAGE_VERSION" \
	--pkgarch="$(dpkg --print-architecture)" \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=utils \
	--pkgsource=index-fm \
	--pakdir=. \
	--maintainer=uri_herrera@nxos.org \
	--provides=index \
	--requires="kio-extras,libkf6kiofilewidgets6,libkf6kiogui6,libqt6multimedia6,libqt6multimediawidgets6,libqt6spatialaudio6,mauikit-archiver \(\>= 4.0.2\),mauikit-filebrowsing \(\>= 4.0.2\),mauikit \(\>= 4.0.2\),qml6-module-qtcore,qml6-module-qtmultimedia,qml6-module-qtquick-effects,qml6-module-qtquick3d-spatialaudio" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
