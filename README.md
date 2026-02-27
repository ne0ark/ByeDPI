# ByeDPI for Unraid

Unraid-ready Docker packaging for [hufrea/byedpi](https://github.com/hufrea/byedpi).

This image compiles upstream `ciadpi` and runs it with Unraid-friendly defaults:
- `PUID` / `PGID` user mapping,
- persistent `/config`,
- `--evaluate` enabled by default,
- environment or config-file based tuning.

## Quick start (Unraid)

1. Build image:
   ```bash
   docker build -t byedpi-unraid:latest .
   ```

   Optional: build a specific upstream ref/tag:
   ```bash
   docker build -t byedpi-unraid:latest \
     --build-arg BYEDPI_REF=master \
     .
   ```

2. In **Unraid → Docker → Add Container**:
   - Repository: `byedpi-unraid:latest`
   - Network type: `bridge`
   - Port: Host `<your port>` → Container `1080`
   - Path: `/mnt/user/appdata/byedpi` → `/config`

3. Recommended env vars:
   - `PUID=99`
   - `PGID=100`
   - `TZ=UTC`

4. Start container and check logs:
   ```bash
   docker logs -f byedpi
   ```

## Default evaluate behavior

Default runtime args are:

```text
--evaluate
```

`--evaluate` is kept as the default because it is the safest network-specific auto-tuning mode for first deployment. After evaluation, you can lock in stable args via config.

### Argument precedence

1. If container command arguments are supplied, those are used directly.
2. Else if `/config/byedpi.args` exists, that file is used.
3. Else `BYEDPI_ARGS` is used (default: `--evaluate`).

### Config file format (`/config/byedpi.args`)

- whitespace-separated CLI args,
- blank lines are ignored,
- lines beginning with `#` are ignored.

Example:

```text
# keep evaluate enabled
--evaluate
```

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `PUID` | `99` | Runtime UID for Unraid permissions. |
| `PGID` | `100` | Runtime GID for Unraid permissions. |
| `TZ` | `UTC` | Timezone. |
| `LISTEN_ADDR` | `0.0.0.0` | Bind address passed to `ciadpi -i`. |
| `LISTEN_PORT` | `1080` | Bind port passed to `ciadpi -p`. |
| `BYEDPI_ARGS` | `--evaluate` | Default args when config file is absent. |
| `BYEDPI_CONFIG` | `/config/byedpi.args` | Path to optional args file. |

## Troubleshooting

- **Proxy not reachable**
  - verify Unraid port mapping,
  - verify `LISTEN_ADDR=0.0.0.0`,
  - verify clients point to correct host IP/port.

- **Permission errors under `/config`**
  - set `PUID`/`PGID` to match Unraid share permissions.

- **Unexpected arguments**
  - check whether `/config/byedpi.args` exists (it overrides `BYEDPI_ARGS`).

## Updating

1. Rebuild/pull the newer image.
2. Recreate container with the same `/config` mapping.
3. Verify startup logs and connectivity.
