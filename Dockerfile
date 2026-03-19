# Dockerfile to build a static snmpwalk binary with DES support
FROM alpine:3.23 AS builder

# Argument for net-snmp version (can be overridden with --build-arg)
ARG NET_SNMP_VERSION=v5.9.5.2

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    openssl-dev \
    openssl-libs-static \
    zlib-dev \
    zlib-static \
    autoconf \
    automake \
    libtool \
    m4 \
    bash \
    linux-headers \
    groff \
    git

# Clone net-snmp source from GitHub
RUN git clone --branch ${NET_SNMP_VERSION} --depth 1 https://github.com/net-snmp/net-snmp.git /build/net-snmp

# Generate configure script using autoreconf
WORKDIR /build/net-snmp

RUN autoreconf -fiv

# Configure and build net-snmp with DES support (via OpenSSL)
RUN ./configure \
    --with-openssl \
    --with-mibs= \
    --without-perl-modules \
    --disable-scripts \
    --prefix=/usr/local

# Build only snmplib first
RUN make -j$(nproc) -C snmplib

# Build snmpwalk with FULL static linking
RUN cd apps && \
    gcc -static -Wl,-Bstatic -I../include -I. -I../agent -I../agent/helpers -I../agent/mibgroup -I../snmplib \
    -g -O2 -DNETSNMP_ENABLE_IPV6 -o snmpwalk snmpwalk.c \
    ../snmplib/.libs/libnetsnmp.a \
    /usr/lib/libssl.a /usr/lib/libcrypto.a -lz -lm

# Install
RUN mkdir -p /usr/local/bin && cp apps/snmpwalk /usr/local/bin/

# Final stage - create minimal image with busybox
FROM busybox:latest

# Copy the snmpwalk binary from builder
COPY --from=builder /usr/local/bin/snmpwalk /snmpwalk

# Set default command
ENTRYPOINT ["/snmpwalk"]
