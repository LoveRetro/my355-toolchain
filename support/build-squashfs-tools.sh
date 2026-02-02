#! /bin/bash

set -euo pipefail

# squashfs-tools
git clone --depth=1 https://github.com/plougher/squashfs-tools.git /tmp/squashfs-tools && \
    cd /tmp/squashfs-tools/squashfs-tools && \
    make -j$(nproc) && make INSTALL_PREFIX=$SYSROOT/usr install && \
    cp mksquashfs unsquashfs "${SYSROOT}/usr/bin/" && \
    cd /tmp && rm -rf /tmp/squashfs-tools