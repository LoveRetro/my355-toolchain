FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN dpkg --add-architecture arm64
RUN apt-get -y update && apt-get -y install \
    # build-essential \
    cmake \
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu \
    git \
	golang \
    make \
    pkg-config \
    wget \
    autoconf \
    automake \
    libtool \
    autopoint \
    && echo "done"

RUN apt-get -y install \
    libsdl2-dev:arm64 \
    libsdl2-image-dev:arm64 \
    libsdl2-ttf-dev:arm64 \
    libgles2-mesa-dev:arm64 \
    libzip-dev:arm64 \
    libbz2-dev:arm64 \
    libsqlite3-dev:arm64 \
    libsamplerate0-dev:arm64 \
    squashfs-tools:arm64 \
    && echo "done"

ENV TOOLCHAIN_DIR=/opt/aarch64-nextui-linux-gnu
RUN mkdir -p ${TOOLCHAIN_DIR}
    
ENV CROSS_TRIPLE=aarch64-linux-gnu
ENV CROSS_ROOT=${TOOLCHAIN_DIR}

ENV AS=${CROSS_TRIPLE}-as \
    AR=${CROSS_TRIPLE}-ar \
    CC=${CROSS_TRIPLE}-gcc \
    CPP=${CROSS_TRIPLE}-cpp \
    CXX=${CROSS_TRIPLE}-g++ \
    LD=${CROSS_TRIPLE}-ld

ENV PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig

ENV CROSS_COMPILE=aarch64-linux-gnu-
ENV PREFIX=/usr

ENV ARCH=arm64

# CMake toolchain
COPY toolchain-aarch64.cmake ${CROSS_ROOT}/Toolchain.cmake
ENV CMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/Toolchain.cmake

COPY support .
# RUN ./build-SDL2.sh
# RUN ./build-zlib.sh
#RUN ./build-libzip.sh
# RUN ./build-bluez.sh not needed
# RUN ./build-autotools.sh
#RUN ./build-libsamplerate.sh
RUN ./build-tinyalsa.sh
# RUN rm -rf /tmp/cache

ENV UNION_PLATFORM=my355

ENV PREFIX_LOCAL=/opt/nextui
RUN mkdir -p ${PREFIX_LOCAL}/include
RUN mkdir -p ${PREFIX_LOCAL}/lib

RUN mkdir -p /root/workspace
VOLUME /root/workspace
WORKDIR /root/workspace


CMD ["/bin/bash"]
