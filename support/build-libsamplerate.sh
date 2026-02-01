#! /bin/sh

# libsamplerate
mkdir -p ~/builds && cd ~/builds
git clone --depth 1 --branch "0.2.2" https://github.com/libsndfile/libsamplerate.git
cd libsamplerate
./autogen.sh
mkdir -p build && cd build
../configure --prefix=/usr
make
make install