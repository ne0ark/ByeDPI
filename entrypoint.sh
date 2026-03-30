#!/bin/sh
set -e

CMD="/usr/local/bin/ciadpi"

# Build args from env vars
CMD_ARGS=""

if [ -n "${BIND_IP}" ]; then
    CMD_ARGS="${CMD_ARGS} --ip ${BIND_IP}"
fi

if [ -n "${PROXY_PORT}" ]; then
    CMD_ARGS="${CMD_ARGS} --port ${PROXY_PORT}"
fi

if [ -n "${BYPASS_METHOD}" ]; then
    CMD_ARGS="${CMD_ARGS} ${BYPASS_METHOD}"
fi

if [ -n "${MAX_CONNECTIONS}" ]; then
    CMD_ARGS="${CMD_ARGS} --max-conn ${MAX_CONNECTIONS}"
fi

if [ -n "${FAKE_TTL}" ]; then
    CMD_ARGS="${CMD_ARGS} --ttl ${FAKE_TTL}"
fi

if [ -n "${TCP_FASTOPEN}" ] && [ "${TCP_FASTOPEN}" != "0" ]; then
    CMD_ARGS="${CMD_ARGS} --tfo"
fi

if [ -n "${EXTRA_ARGS}" ]; then
    CMD_ARGS="${CMD_ARGS} ${EXTRA_ARGS}"
fi

echo "[ByeDPI] Starting with args: ${CMD} ${CMD_ARGS}"
exec ${CMD} ${CMD_ARGS}
