# Small docker image with bash and htslib (e.g. tabix)
# Installs curl so that htslib works with cloud URLs

ARG alpine_version=latest

# Start with alpine linux base
FROM alpine:${alpine_version}

ARG htslib_version=1.9

# tcc: quicker compilation of smaller, slower executables
# gcc: slower compilation of larger, faster executables
ARG compiler=gcc
ARG htslib_url=https://github.com/samtools/htslib/releases/download/${htslib_version}/htslib-${htslib_version}.tar.bz2

RUN \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" \
        >> /etc/apk/repositories && \
    apk --no-cache add bash ${compiler} musl-dev binutils make \
                       zlib-dev bzip2-dev xz-dev curl-dev && \
    wget ${htslib_url} && \
    bzip2 -cd htslib-${htslib_version}.tar.bz2 | tar -xvvf - && \
    rm htslib-${htslib_version}.tar.bz2 && \
    cd htslib-${htslib_version} && \
    ./configure --prefix=/ CC=$(which tcc) --enable-libcurl && \
    make && \
    make install && \
    cd .. && \
    rm -r htslib-${htslib_version} && \
    apk del ${compiler} musl-dev binutils make

# Set environment variables.
ENV HOME=/root

# Define default command.
CMD ["bash"]
