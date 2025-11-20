# CodeServerDocker

A small Docker setup that installs code-server (VS Code in the browser) on an Ubuntu base, runs an `entrypoint.sh`, and includes an installer script for GitHub Copilot and LFS setup.

This repository contains the Dockerfile and helper scripts to build a container image running code-server.

## What this does

- Installs code-server via the upstream installer.
- Copies and (attempts to) run `install-copilot.sh` during image build to install Copilot extensions.
- Adds an `entrypoint.sh` that is used as the container entrypoint and starts code-server inside the container.

## Files of interest

- `Dockerfile` - image definition. Exposes port `8443` and sets `ENTRYPOINT` to `/usr/local/bin/entrypoint.sh`.
- `build.sh` - convenience script to build, tag and push the Docker image. This script requires a version argument and accepts an optional boolean flag to also tag/push the image as `latest`.
- `entrypoint.sh` - container entrypoint; responsible for starting code-server.
- `install-copilot.sh` - installer for GitHub Copilot extensions; may run during build.
- `setup-lfs.sh` - helper to configure Git LFS (if used).

## Build

You can build the image either with the included `build.sh` (preferred) or with `docker build` directly.

Using the provided script:

```bash
# Usage: ./build.sh <version> <latest_flag>
# Example: ./build.sh 4.105.1 true
./build.sh <version> <latest_flag>
```

Notes:
- The script requires the version argument (it is used both as the `CODE_VERSION` build-arg and as the image tag).
- The second argument is a boolean-like flag (`true`/`false`). If `true`, the script will additionally tag and push the image as `latest`.
- The script builds and then pushes the image to Docker Hub using the image name `knight1988/code-server`.
- Make sure you're logged in to Docker Hub (run `docker login`) before running the script so the push succeeds.

If you prefer to build manually, you can still use `docker build` and `docker push` yourself:

```bash
docker build --build-arg CODE_VERSION=<version> -t knight1988/code-server:<version> .
docker push knight1988/code-server:<version>
```

Replace `<version>` with a specific release tag for reproducible images.

## Run

Run the container and map the exposed port `8443` to a host port. Mount a directory if you want persistent workspace/configuration.

Example (map current directory to the container `WORKDIR` `/config`):

```bash
docker run --rm -it \
  -p 8443:8443 \
  -v "$PWD":/config \
  --name codeserver knight1988/code-server:latest
```

Adjust the image name/tag to the image you built (for example `knight1988/code-server:<version>`). The container's `WORKDIR` and `HOME` are set to `/config` in the Dockerfile.

Note: the `Dockerfile` exposes port `8443` and `entrypoint.sh` is used as the container entrypoint; inspect `entrypoint.sh` if you need to change startup flags (password, auth, TLS, etc.).

## Build arguments

- `CODE_VERSION` - Build-arg used to control which version of code-server is installed. The included `build.sh` uses the first CLI argument as this value and will fail if it is omitted. When building manually you may leave this as `latest` or set a specific tag for reproducible images.

## Troubleshooting

- The build runs `install-copilot.sh` but the Dockerfile allows it to fail (the script is run with `|| echo "... continuing"`). If Copilot installation fails during build, inspect `install-copilot.sh` and consider running it manually inside a running container to debug.
- If you need persistent settings, mount a host directory to `/config` (the container `WORKDIR`).
- Check container logs: `docker logs <container-name>` for runtime errors.

## Assumptions

- This README assumes the repository's `build.sh` script (if present) is a convenience wrapper to build the image. If it behaves differently, review the script.