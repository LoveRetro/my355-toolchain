#! /bin/bash

set -euo pipefail

# sdl (SDL2 branch)
git clone --depth=1 --branch SDL2 https://github.com/libsdl-org/SDL.git /tmp/SDL && \
    mkdir /tmp/SDL/build && cd /tmp/SDL/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DSDL_STATIC=OFF \
        -DSDL_SHARED=ON && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/SDL

# sdl_image
git clone --depth=1 --branch SDL2 https://github.com/libsdl-org/SDL_image.git /tmp/SDL_image && \
    mkdir /tmp/SDL_image/build && cd /tmp/SDL_image/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DSDL2IMAGE_STATIC=OFF \
        -DSDL2IMAGE_SHARED=ON && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/SDL_image

# freetype
git clone --depth=1 https://github.com/freetype/freetype.git /tmp/freetype && \
    mkdir /tmp/freetype/build && cd /tmp/freetype/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DFT_WITH_ZLIB=ON \
        -DBUILD_SHARED_LIBS=ON && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/freetype

# sdl_ttf
git clone --depth=1 --branch SDL2 https://github.com/libsdl-org/SDL_ttf.git /tmp/SDL_ttf && \
    mkdir /tmp/SDL_ttf/build && cd /tmp/SDL_ttf/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DSDL2TTF_STATIC=OFF \
        -DSDL2TTF_SHARED=ON && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/SDL_ttf
