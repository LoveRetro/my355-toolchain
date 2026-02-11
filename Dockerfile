# syntax=docker/dockerfile:1
FROM docker.io/library/ubuntu:24.04 AS base
ENV DEBIAN_FRONTEND=noninteractive

# Install base build tools and dependencies
RUN apt-get update && apt-get install -y \
    make \
    cmake \
    ninja-build \
    autotools-dev \
    autoconf \
    automake \
    autopoint \
    libtool \
    po4a \
    m4 \
    pkg-config \
    unzip \
    wget \
    git \
    python3 \
    ca-certificates \
    gettext \
    vim \
    golang \
    python3-pip \
    gperf \
    bison \
    flex \
    python3-mako \
    xsltproc \
    docbook-xsl \
    docbook-xml \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages meson jinja2

ENV TOOLCHAIN_DIR=/opt/aarch64-nextui-linux-gnu
ENV CROSS_TRIPLE=aarch64-nextui-linux-gnu
ENV CROSS_ROOT=${TOOLCHAIN_DIR}
ENV SYSROOT=${CROSS_ROOT}/${CROSS_TRIPLE}/libc

ENV AS=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gcc \
    CPP=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cpp \
    CXX=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-g++ \
    LD=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ld

ENV PATH=${CROSS_ROOT}/bin:${PATH}
ENV CROSS_COMPILE=${CROSS_TRIPLE}-
ENV PREFIX=${SYSROOT}/usr
ENV ARCH=aarch64
ENV PKG_CONFIG_SYSROOT_DIR=${SYSROOT}
ENV PKG_CONFIG_PATH=${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig

# --- Stage 1: Build environment (Native on build host) ---
FROM --platform=$BUILDPLATFORM base AS builder
ARG BUILDARCH

# Download the toolchain for the BUILDER host architecture
RUN mkdir -p ${TOOLCHAIN_DIR} && \
    TOOLCHAIN_REPO=https://github.com/LoveRetro/gcc-arm-8.3-aarch64-my355 && \
    TOOLCHAIN_BUILD=v8.3.0-20260126-120301-66f7801c && \
    if [ "$BUILDARCH" = "amd64" ]; then \
        TOOLCHAIN_ARCHIVE=gcc-8.3.0-aarch64-nextui-linux-gnu-x86_64-host.tar.xz; \
    elif [ "$BUILDARCH" = "arm64" ]; then \
        TOOLCHAIN_ARCHIVE=gcc-8.3.0-aarch64-nextui-linux-gnu-arm64-host.tar.xz; \
    else \
        echo "Unsupported build architecture: $BUILDARCH" && exit 1; \
    fi && \
    TOOLCHAIN_URL=${TOOLCHAIN_REPO}/releases/download/${TOOLCHAIN_BUILD}/${TOOLCHAIN_ARCHIVE}; \
    wget -qO - $TOOLCHAIN_URL | tar -xJ -C ${TOOLCHAIN_DIR} --strip-components=2

# Copy scripts and build everything
COPY support /root/support
COPY toolchain-aarch64.cmake ${CROSS_ROOT}/Toolchain.cmake

RUN /root/support/build-libzip.sh && \
    /root/support/build-libsamplerate.sh && \
    /root/support/build-lz4.sh && \
    /root/support/build-squashfs-tools.sh && \
    /root/support/build-tinyalsa.sh && \
    /root/support/build-mali.sh && \
    /root/support/build-dbus.sh && \
    /root/support/build-sdl.sh && \
    /root/support/build-sqlite.sh

# --- Stage 2: Final Image ---
FROM base AS final
ARG TARGETARCH

# Download the toolchain for the TARGET architecture (so it can run inside the container)
RUN mkdir -p ${TOOLCHAIN_DIR} && \
    TOOLCHAIN_REPO=https://github.com/LoveRetro/gcc-arm-8.3-aarch64-my355 && \
    TOOLCHAIN_BUILD=v8.3.0-20260126-120301-66f7801c && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        TOOLCHAIN_ARCHIVE=gcc-8.3.0-aarch64-nextui-linux-gnu-x86_64-host.tar.xz; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        TOOLCHAIN_ARCHIVE=gcc-8.3.0-aarch64-nextui-linux-gnu-arm64-host.tar.xz; \
    else \
        echo "Unsupported target architecture: $TARGETARCH" && exit 1; \
    fi && \
    TOOLCHAIN_URL=${TOOLCHAIN_REPO}/releases/download/${TOOLCHAIN_BUILD}/${TOOLCHAIN_ARCHIVE}; \
    wget -qO - $TOOLCHAIN_URL | tar -xJ -C ${TOOLCHAIN_DIR} --strip-components=2

# Copy the pre-built libraries from the builder stage
# Since these are cross-compiled for aarch64, they are platform-independent
COPY --from=builder ${SYSROOT}/usr ${SYSROOT}/usr
COPY toolchain-aarch64.cmake ${CROSS_ROOT}/Toolchain.cmake

ENV UNION_PLATFORM=my355
ENV PREFIX_LOCAL=/opt/nextui
RUN mkdir -p ${PREFIX_LOCAL}/include ${PREFIX_LOCAL}/lib

VOLUME /root/workspace
WORKDIR /root/workspace
