#! /bin/bash

set -euo pipefail

# tinyalsa
git clone --depth=1 --branch v2.0.0 https://github.com/tinyalsa/tinyalsa.git /tmp/tinyalsa && \
    cd /tmp/tinyalsa && \
    meson setup build --prefix=$SYSROOT/usr --libdir=lib -Dbuildtype=release && \
    ninja -C build install && \
    cd /tmp && rm -rf /tmp/tinyalsa