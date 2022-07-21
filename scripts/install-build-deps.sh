#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt-get"
else
    APT_COMMAND="apt-get"
fi

$APT_COMMAND update -q
$APT_COMMAND install -qy --no-install-recommends \
    appstream \
    automake \
    autotools-dev \
    build-essential \
    checkinstall \
    cmake \
    curl \
    devscripts \
    equivs \
    extra-cmake-modules \
    gettext \
    git \
    gnupg2 \
    libkf5archive-dev \
    libkf5config-dev \
    libkf5coreaddons-dev \
    libkf5i18n-dev \
    libkf5kio-dev \
    libkf5notifications-dev \
    libkf5service-dev \
    libkf5syntaxhighlighting-dev \
    libqt5svg5-dev \
    libwayland-dev \
    lintian \
    qtbase5-dev \
    qtdeclarative5-dev \
    qtquickcontrols2-5-dev \
    qtwayland5 \
    qtwayland5-dev-tools \
    qtwayland5-private-dev
