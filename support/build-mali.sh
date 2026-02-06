#! /bin/bash

set -euo pipefail

# libdrm
git clone --depth=1 https://gitlab.freedesktop.org/mesa/drm.git /tmp/libdrm && \
    cd /tmp/libdrm && \
    meson setup build --prefix=$SYSROOT/usr --libdir=lib -Dbuildtype=release && \
    ninja -C build install && \
    cd /tmp && rm -rf /tmp/libdrm

# libmali blobs from Rocknix: https://github.com/ROCKNIX/libmali.git
# we need to grab drivers for rk3566 here, so bifrost-g52
# build via meson
# I've forked to trim down the original repo, which takes forever to check out.
# Sadly we cant enable LFS here, because you cant migrate to LFS on public forks on Github (meh)
git clone --depth=1 https://github.com/LoveRetro/libmali.git /tmp/libmali && \
    mkdir /tmp/libmali/build && cd /tmp/libmali/build && \
    meson setup .. \
        --prefix=$SYSROOT/usr \
        --libdir=lib \
        --buildtype=release \
        -Dwith-overlay=false \
        -Dgpu=bifrost-g52 \
        -Dversion=g24p0 && \
    ninja && ninja install && \
    cd /tmp && rm -rf /tmp/libmali
