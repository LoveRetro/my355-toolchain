#! /bin/bash

set -euo pipefail

# libcrypto
git clone --depth=1 --branch openssl-3.6.1 https://github.com/openssl/openssl.git /tmp/openssl && \
    cd /tmp/openssl && \
    CROSS_COMPILE= ./config --prefix=$SYSROOT/usr --openssldir=$SYSROOT/usr shared && \
    make -j$(nproc) && make install_sw install_ssldirs install_dev && \
    cd /tmp && rm -rf /tmp/openssl

# lzma/xz
git clone https://github.com/tukaani-project/xz.git /tmp/xz && \
    cd /tmp/xz && \
    ./autogen.sh && \
    ./configure \
       --host=$CROSS_TRIPLE \
        --prefix=$SYSROOT/usr \
        --disable-static \
        --enable-shared \
        --with-sysroot=$SYSROOT && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/xz

# zstd
git clone --depth=1 https://github.com/facebook/zstd.git /tmp/zstd && \
    cd /tmp/zstd/build/cmake && \
    cmake . \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr \
        -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/zstd

# bz2 (shared lib - use Makefile-libbz2_so  instead of Makefile)
wget -q https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz -O /tmp/bzip2.tar.gz && \
    cd /tmp && tar -xzf bzip2.tar.gz && cd bzip2-1.0.8 && \
    make -j$(nproc) && \
    make PREFIX=$SYSROOT/usr install && \
    make -f Makefile-libbz2_so && cp -L libbz2.so* $SYSROOT/usr/lib/ && \
    cd /tmp && rm -rf /tmp/bzip2*

# zlib
wget -q https://zlib.net/zlib-1.3.1.tar.gz -O /tmp/zlib.tar.gz && \
    cd /tmp && tar -xzf zlib.tar.gz && cd zlib-1.3.1 && \
    ./configure --prefix=$SYSROOT/usr --shared && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/zlib*

# libzip
git clone https://github.com/nih-at/libzip.git /tmp/libzip && \
    mkdir /tmp/libzip/build && cd /tmp/libzip/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr \
        -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/libzip