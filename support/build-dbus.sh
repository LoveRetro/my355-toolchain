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

# expat
git clone --depth=1 https://github.com/libexpat/libexpat.git /tmp/expat && \
    cd /tmp/expat/expat && \
    ./buildconf.sh && \
    ./configure --host=$CROSS_TRIPLE --prefix=$SYSROOT/usr && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/expat

# dbus
git clone --depth=1 https://gitlab.freedesktop.org/dbus/dbus.git /tmp/dbus && \
    cd /tmp/dbus && \
    mkdir build && cd build && \
    meson setup .. \
        --cross-file /tmp/cross_file.txt \
        --prefix=$SYSROOT/usr \
        --libdir=lib \
        --buildtype=release \
        -Dsystemd=disabled \
        -Duser_session=false && \
    ninja && ninja install && \
    cd /tmp && rm -rf /tmp/dbus

# eudev (minimal udev)
git clone --depth=1 https://github.com/eudev-project/eudev.git /tmp/eudev && \
    cd /tmp/eudev && \
    ./autogen.sh && \
    ./configure \
        --host=$CROSS_TRIPLE \
        --prefix=$SYSROOT/usr \
        --disable-introspection \
        --disable-hwdb \
        --disable-manpages \
        --disable-static \
        --enable-shared \
        --disable-kmod \
        --disable-blkid && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/eudev