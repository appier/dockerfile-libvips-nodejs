FROM ubuntu:14.04
MAINTAINER Archie Lee (archielee@appier.com)

# libvips 8.3.1
# https://github.com/marcbachmann/dockerfile-libvips/blob/master/Dockerfile
ENV LIBVIPS_VERSION_MAJOR 8
ENV LIBVIPS_VERSION_MINOR 3
ENV LIBVIPS_VERSION_PATCH 1
ENV LIBVIPS_VERSION $LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR.$LIBVIPS_VERSION_PATCH

# node.js 6.2.2
# https://github.com/nodejs/docker-node/blob/master/6.2/Dockerfile
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.2.2

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libcfitsio3-dev \
    libopenslide-dev \
    libpango1.0-dev \
    libmatio-dev \
    swig \
    libxml2-dev \
    libexif-dev \
    libtiff5-dev \
    gobject-introspection \
    libglib2.0-dev \
    libjpeg-turbo8-dev \
    gtk-doc-tools \
    make \
    libpng12-dev \
    automake \
    gcc \
    build-essential \
    g++ \
    cpp \
    libwebp-dev \
    libc6-dev \
    man-db \
    autoconf \
    pkg-config \
    curl \
    git \
    libmagickwand-dev \
    imagemagick

RUN curl -O http://www.vips.ecs.soton.ac.uk/supported/$LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR/vips-$LIBVIPS_VERSION.tar.gz \
  && tar zvxf vips-$LIBVIPS_VERSION.tar.gz \
  && cd vips-$LIBVIPS_VERSION \
  && ./configure --enable-debug=no --without-python --without-orc --without-fftw --without-gsf $1 \
  && make \
  && make install \
  && ldconfig

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

RUN apt-get remove -y curl build-essential \
  && apt-get autoremove -y \
  && apt-get autoclean \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "node" ]
