# VSCode Docker Image Build

This directory contains the build configuration for the VSCode Docker image, which supports multi-architecture builds for both `amd64` and `arm64` platforms.

## Local Development

The Makefile provides several targets for building and pushing the Docker image:

### Setup

Before building, ensure you have Docker with buildx support installed:

```bash
# Check if buildx is available
docker buildx version
```

### Building Images

```bash
# Build for both architectures (arm64 and amd64)
make build-all

# Build only for arm64
make build-arm64

# Build only for amd64
make build-amd64
```

### Pushing Images

To push the image to a container registry:

```bash
# Push with a specific tag
make push REGISTRY=ghcr.io/yourusername TAG=v1.0.0

# The default registry is determined from your git config if not specified
```

### Cleaning Up

```bash
# Remove local images
make clean

# Remove the buildx builder
make clean-builder
```

## GitHub Actions Workflow

This project includes a GitHub Actions workflow that automatically builds and pushes multi-architecture Docker images when:

1. Changes are pushed to the `main` branch affecting files in `charts/vscode/build/` or the workflow file itself
2. A tag starting with `v` is pushed (e.g., `v1.0.0`)
3. A pull request is opened against the `main` branch with changes to the build files
4. The workflow is manually triggered

The workflow:
- Sets up QEMU for multi-architecture emulation
- Configures Docker Buildx
- Logs in to the GitHub Container Registry
- Builds and pushes the image for both `amd64` and `arm64` architectures

### Image Tags

The workflow automatically generates appropriate tags based on:
- Semantic version tags (e.g., `v1.2.3` → `1.2.3` and `1.2`)
- Branch names
- Pull request numbers
- Short commit SHA
- `latest` tag for the default branch

## Dockerfile

The Dockerfile is designed to support multi-architecture builds using the `TARGETARCH` build argument, which is automatically set by Docker buildx based on the target platform.

Architecture-specific installations are handled with conditional logic in the Dockerfile, ensuring that the appropriate binaries are installed for each platform.
