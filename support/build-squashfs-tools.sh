#! /bin/bash

set -euo pipefail

# lzo (shared)
git clone --depth=1 https://github.com/nemequ/lzo /tmp/lzo && \
    cd /tmp/lzo && \
    mkdir build && cd build && \
    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
        -DENABLE_STATIC=0 -DENABLE_SHARED=1 \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr \
        -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/lzo

# squashfs-tools
git clone --depth=1 https://github.com/plougher/squashfs-tools.git /tmp/squashfs-tools && \
    cd /tmp/squashfs-tools/squashfs-tools && \
    make CC="$CC" AR="$AR" -j$(nproc) && \
    make INSTALL_PREFIX=$SYSROOT/usr install && \
    cp mksquashfs unsquashfs "${SYSROOT}/usr/bin/" && \
    cd /tmp && rm -rf /tmp/squashfs-tools