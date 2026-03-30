FROM alpine:latest AS download

ENV BYEDPI_ARCH=x86_64

RUN apk add --no-cache curl tar jq \
 && DOWNLOAD_URL=$(curl -sfL https://api.github.com/repos/hufrea/byedpi/releases/latest \
    | jq -r '.assets[] | select(.name | test("byedpi-[0-9.]+-'${BYEDPI_ARCH}'\\.tar\\.gz")) | .browser_download_url' \
    | head -1) \
 && curl -sfL "$DOWNLOAD_URL" -o /tmp/byedpi.tar.gz \
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
