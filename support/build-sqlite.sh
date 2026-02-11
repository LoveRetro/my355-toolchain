#! /bin/bash

set -euo pipefail

# sqlite3
git clone --depth=1 https://github.com/sqlite/sqlite.git /tmp/sqlite && \
    cd /tmp/sqlite && \
    ./configure \
       --host=$CROSS_TRIPLE \
        --prefix=$SYSROOT/usr \
        --disable-static \
        --enable-shared \
        --sysroot=$SYSROOT && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/sqlite