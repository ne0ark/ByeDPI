#!/bin/sh
set -e

ARCH="${BYEDPI_ARCH:-x86_64}"
API_URL="https://api.github.com/repos/hufrea/byedpi/releases/latest"

echo "Fetching latest release for arch: ${ARCH}"

DOWNLOAD_URL=$(curl -sfL "$API_URL" | grep -o "https://github.com/hufrea/byedpi/releases/download/[^\"]*${ARCH}.tar.gz" | head -1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "ERROR: Could not find download URL for arch ${ARCH}"
    exit 1
fi

echo "Downloading: ${DOWNLOAD_URL}"
curl -sfL "$DOWNLOAD_URL" -o /tmp/byedpi.tar.gz

echo "Extracting..."
tar -xzf /tmp/byedpi.tar.gz -C /tmp

echo "Installing ciadpi..."
install -m 555 /tmp/ciadpi /usr/local/bin/ciadpi

echo "Cleaning up..."
rm -rf /tmp/byedpi.tar.gz /tmp/ciadpi /tmp/byedpi.*
