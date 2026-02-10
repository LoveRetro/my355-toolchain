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

# tinyalsa
git clone --depth=1 --branch v2.0.0 https://github.com/tinyalsa/tinyalsa.git /tmp/tinyalsa && \
    cd /tmp/tinyalsa && \
    meson setup build --cross-file /tmp/cross_file.txt --prefix=$SYSROOT/usr --libdir=lib -Dbuildtype=release && \
    ninja -C build install && \
    cd /tmp && rm -rf /tmp/tinyalsa