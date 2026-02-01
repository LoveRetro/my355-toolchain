#! /bin/sh

# tinyalsa
mkdir ~/builds && cd ~/builds
git clone --depth 1 --branch "v2.0.0" https://github.com/tinyalsa/tinyalsa.git
mkdir -p tinyalsa/build && cd tinyalsa/build
cmake ..
make
make install