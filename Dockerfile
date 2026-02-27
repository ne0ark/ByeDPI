FROM alpine:3.20 AS build

ARG BYEDPI_REPO=https://github.com/hufrea/byedpi
ARG BYEDPI_REF=master

RUN apk add --no-cache \
    git \
    build-base \
    openssl-dev \
    libpcap-dev \
    linux-headers \
    musl-dev

WORKDIR /src
RUN git clone --depth 1 --branch "${BYEDPI_REF}" "${BYEDPI_REPO}" .
RUN LDFLAGS=-static make

FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    ca-certificates \
    tzdata \
    su-exec

COPY --from=build /src/ciadpi /usr/local/bin/ciadpi
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/ciadpi /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /config

ENV PUID=99 \
    PGID=100 \
    TZ=UTC \
    LISTEN_ADDR=0.0.0.0 \
    LISTEN_PORT=1080 \
    BYEDPI_ARGS="--evaluate" \
    BYEDPI_CONFIG=/config/byedpi.args

WORKDIR /config
EXPOSE 1080/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD pidof ciadpi >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
