FROM alpine:latest AS download

ENV BYEDPI_VERSION=0.17.3
ENV BYEDPI_ARCH=x86_64

RUN apk add --no-cache curl tar \
 && curl -sL "https://github.com/hufrea/byedpi/releases/download/v${BYEDPI_VERSION}/byedpi-${BYEDPI_VERSION}-${BYEDPI_ARCH}.tar.gz" \
    -o /tmp/byedpi.tar.gz \
 && tar -xzf /tmp/byedpi.tar.gz -C /tmp \
 && install -m 555 /tmp/ciadpi /usr/local/bin/ciadpi \
 && rm -rf /tmp/byedpi.tar.gz /tmp/ciadpi /tmp/byedpi.*

FROM alpine:latest

RUN apk add --no-cache libpcap ca-certificates bash

COPY --from=download /usr/local/bin/ciadpi /usr/local/bin/ciadpi
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1080

ENTRYPOINT ["/entrypoint.sh"]
