#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${TZ:-}" && -f "/usr/share/zoneinfo/${TZ}" ]]; then
  ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
  echo "${TZ}" >/etc/timezone
fi

find_group_by_gid() {
  awk -F: -v gid="$1" '$3 == gid { print $1; exit }' /etc/group
}

find_user_by_uid() {
  awk -F: -v uid="$1" '$3 == uid { print $1; exit }' /etc/passwd
}

runtime_group="$(find_group_by_gid "${PGID}")"
if [[ -z "${runtime_group}" ]]; then
  runtime_group="byedpi"
  addgroup -S -g "${PGID}" "${runtime_group}" >/dev/null 2>&1 || true
fi

runtime_user="$(find_user_by_uid "${PUID}")"
if [[ -z "${runtime_user}" ]]; then
  runtime_user="byedpi"
  adduser -S -D -H -u "${PUID}" -G "${runtime_group}" "${runtime_user}" >/dev/null 2>&1 || true
fi

mkdir -p /config
chown "${PUID}:${PGID}" /config || true

if [[ $# -gt 0 ]]; then
  exec su-exec "${runtime_user}:${runtime_group}" ciadpi "$@"
fi

selected_args="${BYEDPI_ARGS:-}"
if [[ -n "${BYEDPI_CONFIG:-}" && -f "${BYEDPI_CONFIG}" ]]; then
  selected_args="$(sed -E '/^\s*($|#)/d' "${BYEDPI_CONFIG}" | tr '\n' ' ')"
fi

ciadpi_args=( -i "${LISTEN_ADDR}" -p "${LISTEN_PORT}" )
if [[ -n "${selected_args}" ]]; then
  # shellcheck disable=SC2206
  extra_args=( ${selected_args} )
  ciadpi_args+=( "${extra_args[@]}" )
fi

exec su-exec "${runtime_user}:${runtime_group}" ciadpi "${ciadpi_args[@]}"
