FROM alpine:latest AS download

ENV BYEDPI_ARCH=x86_64

COPY download.sh /tmp/download.sh
RUN apk add --no-cache curl tar \
 && chmod +x /tmp/download.sh \
 && /tmp/download.sh

FROM alpine:latest

RUN apk add --no-cache libpcap ca-certificates bash

COPY --from=download /usr/local/bin/ciadpi /usr/local/bin/ciadpi
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1080

ENTRYPOINT ["/entrypoint.sh"]
