#! /bin/bash

set -euo pipefail

# Create a cross file for meson
cat > /tmp/cross_file.txt <<EOF
[binaries]
c = '${CROSS_TRIPLE}-gcc'
cpp = '${CROSS_TRIPLE}-g++'
ar = '${CROSS_TRIPLE}-ar'
strip = '${CROSS_TRIPLE}-strip'
pkgconfig = 'pkg-config'

[host_machine]
system = 'linux'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
EOF

# libdrm
git clone --depth=1 https://gitlab.freedesktop.org/mesa/drm.git /tmp/libdrm && \
    mkdir /tmp/libdrm/build && cd /tmp/libdrm/build && \
    meson setup .. \
        --cross-file /tmp/cross_file.txt \
        --prefix=$SYSROOT/usr \
        --libdir=lib \
        --buildtype=release \
        -Dvc4=disabled \
        -Dintel=disabled \
        -Dvmwgfx=disabled \
        -Dradeon=disabled \
        -Damdgpu=disabled \
        -Dnouveau=disabled \
        -Dfreedreno=disabled \
        -Dinstall-test-programs=false \
        -Dcairo-tests=disabled \
        -Dvalgrind=disabled && \
    ninja && ninja install && \
    cd /tmp && rm -rf /tmp/libdrm

# libglvnd
git clone --depth=1 https://gitlab.freedesktop.org/glvnd/libglvnd.git /tmp/libglvnd && \
    mkdir /tmp/libglvnd/build && cd /tmp/libglvnd/build && \
    meson setup .. \
        --cross-file /tmp/cross_file.txt \
        --prefix=$SYSROOT/usr \
        --libdir=lib \
        --buildtype=release && \
    ninja && ninja install && \
    cd /tmp && rm -rf /tmp/libglvnd

# mesa
git clone --depth=1 https://gitlab.freedesktop.org/mesa/mesa.git /tmp/mesa && \
    cd /tmp/mesa && \
    meson setup build-host \
        -Dtools=panfrost \
        -Dmesa-clc=enabled \
        -Dinstall-mesa-clc=true \
        -Dprecomp-compiler=enabled \
        -Dinstall-precomp-compiler=true \
        -Dgallium-drivers= \
        -Dvulkan-drivers= \
        -Dglx=disabled \
        --prefix=/usr && \
    meson compile -C build-host && meson install -C build-host && \
    mkdir /tmp/mesa/build && cd /tmp/mesa/build && \
    meson setup .. \
        --cross-file /tmp/cross_file.txt \
        --prefix=$SYSROOT/usr \
        --libdir=lib \
        --buildtype=release \
        -Dplatforms= \
        -Dglx=disabled \
        -Dgles1=disabled \
        -Dgles2=enabled \
        -Degl=enabled \
        -Dgbm=enabled \
        -Dshared-glapi=enabled \
        -Dgallium-drivers=panfrost \
        -Dvulkan-drivers=panfrost \
        -Dllvm=disabled \
        -Dmesa-clc=system \
        -Dprecomp-compiler=system && \
    meson compile && meson install && \
    cd /tmp && rm -rf /tmp/mesa /tmp/cross_file.txt