# coder-custom

A custom Docker image built on top of the official `coder/coder` image, pre-configured with commonly used Terraform providers and tools.

## Features

- Based on official `coder/coder:v2.23.2` image
- Pre-installed Terraform providers:
  - `coder/coder` v2.8.0
  - `kreuzwerker/docker` v3.6.2
  - `hashicorp/kubernetes` v2.37.1
  - `harvester/harvester` v0.6.7
- Terraform offline mirror support configured
- Additional tools: `curl`, `unzip`

## Quick Start

### Build the image

```bash
docker build -t coder-custom:latest .
```

### Run the container

```bash
docker run -d -p 8080:8080 coder-custom:latest
```

## Image Architecture

This image extends the official Coder image by:

1. Installing additional CLI tools (`curl`, `unzip`)
2. Creating Terraform plugin directory structure
3. Downloading and installing Terraform providers
4. Configuring `.terraformrc` for offline provider installation

## Customizing Providers

To add or modify Terraform providers, edit the `Dockerfile`:

1. Add a new ARG for the provider version
2. Create the directory structure and download the provider

```dockerfile
ARG PROVIDER_VERSION=x.x.x
RUN echo "Adding owner/provider v${PROVIDER_VERSION}" \
    && mkdir -p owner/provider && cd owner/provider \
    && curl -LOs https://github.com/owner/terraform-provider-provider/releases/download/v${PROVIDER_VERSION}/terraform-provider-provider_${PROVIDER_VERSION}_linux_amd64.zip
```

## CI/CD

This project uses Renovate Bot + GitHub Actions for fully automated dependency updates and image builds:

- Renovate detects new Terraform provider versions and base image updates, opens PRs and auto-merges
- GitHub Actions builds and pushes the image to `ghcr.io/w0n9/coder` on every Dockerfile change to master
- Image tags: `v{base_version}-{YYYYMMDD}` + `latest`

## Configuration

### Build Arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `CODER_PROVIDER_VERSION` | `2.8.0` | Coder Terraform provider version |
| `DOCKER_PROVIDER_VERSION` | `3.6.2` | Docker Terraform provider version |
| `KUBERNETES_PROVIDER_VERSION` | `2.37.1` | Kubernetes Terraform provider version |
| `HARVESTER_PROVIDER_VERSION` | `0.6.7` | Harvester Terraform provider version |

### Example with custom versions

```bash
docker build \
  --build-arg CODER_PROVIDER_VERSION=2.9.0 \
  --build-arg DOCKER_PROVIDER_VERSION=3.7.0 \
  -t coder-custom:latest .
```

## Versioning

Image tags follow the format `v<CoderVersion>-<YYYYMMDD>`. For example, `v2.23.2-20260529` means:
- Coder base image version: 2.23.2
- Build date: 2026-05-29

## License

MIT
