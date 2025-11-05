# CodeServerDocker

A small Docker setup that installs code-server (VS Code in the browser) on an Ubuntu base, runs an `entrypoint.sh`, and includes an installer script for GitHub Copilot and LFS setup.

This repository contains the Dockerfile and helper scripts to build a container image running code-server.

## What this does

- Installs code-server via the upstream installer.
- Copies and (attempts to) run `install-copilot.sh` during image build to install Copilot extensions.
- Adds an `entrypoint.sh` that is used as the container entrypoint and starts code-server inside the container.

## Files of interest

- `Dockerfile` - image definition. Exposes port `8443` and sets `ENTRYPOINT` to `/usr/local/bin/entrypoint.sh`.
- `build.sh` - convenience script to build the Docker image (if present).
- `entrypoint.sh` - container entrypoint; responsible for starting code-server.
- `install-copilot.sh` - installer for GitHub Copilot extensions; may run during build.
- `setup-lfs.sh` - helper to configure Git LFS (if used).

## Build

You can build the image either with the included `build.sh` (if present and executable) or with `docker build` directly.

Using the provided script (preferred if available):

```bash
./build.sh
```

Or build manually and optionally set the code-server version:

```bash
docker build --build-arg CODE_VERSION=latest -t codeserverdocker:latest .
```

Replace `latest` with a specific release tag if desired (for reproducible images).

## Run

Run the container and map the exposed port `8443` to a host port. Mount a directory if you want persistent workspace/configuration.

Example (map current directory to the container `WORKDIR` `/config`):

```bash
docker run --rm -it \
  -p 8443:8443 \
  -v "$PWD":/config \
  --name codeserver docker/codeserverdocker:latest
```

Adjust the image name/tag to whatever you used when building (for example `codeserverdocker:latest`). The container's `WORKDIR` and `HOME` are set to `/config` in the Dockerfile.

Note: the `Dockerfile` exposes port `8443` and `entrypoint.sh` is used as the container entrypoint; inspect `entrypoint.sh` if you need to change startup flags (password, auth, TLS, etc.).

## Build arguments

- `CODE_VERSION` - Build-arg used to control which version of code-server is installed. Default is `latest`.

## Troubleshooting

- The build runs `install-copilot.sh` but the Dockerfile allows it to fail (the script is run with `|| echo "... continuing"`). If Copilot installation fails during build, inspect `install-copilot.sh` and consider running it manually inside a running container to debug.
- If you need persistent settings, mount a host directory to `/config` (the container `WORKDIR`).
- Check container logs: `docker logs <container-name>` for runtime errors.

## Assumptions

- This README assumes the repository's `build.sh` script (if present) is a convenience wrapper to build the image. If it behaves differently, review the script.