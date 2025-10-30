FROM alpine:latest AS build

RUN apk update && apk add --no-cache \
            git \
            build-base \
            openssl-dev \
            libpcap-dev \
            linux-headers \
            musl-dev

RUN git clone https://github.com/hufrea/byedpi /opt/byedpi

WORKDIR /opt/byedpi
RUN LDFLAGS=-static make
        
FROM alpine:latest

COPY --from=build /opt /opt
EXPOSE 1080

ENTRYPOINT ["/opt/byedpi/ciadpi"]
