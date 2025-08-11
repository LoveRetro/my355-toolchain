FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update && apt-get -y install \
	bc \
    build-essential \
    bzip2 \
	bzr \
	cmake \
	cmake-curses-gui \
	cpio \
	device-tree-compiler \
	git \
	golang \
	libncurses5-dev \
	libsdl1.2-dev \
	libsdl-image1.2-dev \
	libsdl-ttf2.0-dev \
	libsdl2-dev \
	libsdl2-image-dev \
	libsdl2-ttf-dev \
	libsqlite3-dev \
	locales \
	make \
	rsync \
	scons \
	squashfs-tools \
	tree \
	unzip \
	wget \
	libsamplerate0-dev \
    liblzma-dev \ 
    libzstd-dev \
    libbz2-dev \
    zlib1g-dev \
	locales \
    make \
    rsync \
    scons \
    tree \
    unzip \
    wget \
	bluetooth \
	bluez\ 
	bluez-test-tools \ 
	bluez-obexd \
	autoconf \
    automake \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/workspace
WORKDIR /root

COPY support .
# build newer libzip from source
RUN ./build-libzip.sh

# build autotools (for bluez)
RUN ./build-autotools.sh > /root/builds/autotools.log
# RUN ./build-bluez.sh > /root/builds/bluez.log

RUN cat setup-env.sh >> .bashrc

#ENV LD_PREFIX=/usr/aarch64-linux-gnu \
#      PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig

VOLUME /root/workspace
WORKDIR /root/workspace

CMD ["/bin/bash"]
