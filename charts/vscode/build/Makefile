# Image name and registry configuration
IMAGE_NAME ?= vscode-codespace
REGISTRY ?= ghcr.io/$(shell git config --get remote.origin.url | sed -n 's/.*github.com[:/]\([^/]*\).*/\1/p')
BUILDER_NAME := multiarch-builder

# Default target: build for both architectures
all: build-all

# Setup buildx builder for multi-architecture builds
setup-builder:
	@echo "Setting up buildx builder for multi-architecture builds..."
	docker buildx ls | grep $(BUILDER_NAME) || docker buildx create --name $(BUILDER_NAME) --driver docker-container --use

# Build for arm64 architecture
build-arm64: setup-builder
	@echo "Building for arm64 architecture..."
	docker buildx build --builder $(BUILDER_NAME) --platform linux/arm64 -t $(IMAGE_NAME):arm64 --load .

# Build for amd64 architecture
build-amd64: setup-builder
	@echo "Building for amd64 architecture..."
	docker buildx build --builder $(BUILDER_NAME) --platform linux/amd64 -t $(IMAGE_NAME):amd64 --load .

# Build for both architectures (local development)
build-all: setup-builder
	@echo "Building for both arm64 and amd64 architectures..."
	docker buildx build --builder $(BUILDER_NAME) --platform linux/arm64,linux/amd64 -t $(IMAGE_NAME):latest --load .

# Push images to a registry (requires login first)
# Usage: make push REGISTRY=your-registry.com/username TAG=v1.0.0
push: setup-builder
	@echo "Pushing images to registry $(REGISTRY)..."
	docker buildx build --builder $(BUILDER_NAME) --platform linux/arm64,linux/amd64 -t $(REGISTRY)/$(IMAGE_NAME):$(TAG) -t $(REGISTRY)/$(IMAGE_NAME):latest --push .

# Clean up images
clean:
	@echo "Removing local images..."
	-docker rmi $(IMAGE_NAME):arm64 $(IMAGE_NAME):amd64 $(IMAGE_NAME):latest

# Remove buildx builder
clean-builder:
	@echo "Removing buildx builder..."
	-docker buildx rm $(BUILDER_NAME)

# Build and push with GitHub Actions compatible settings
ci-build: setup-builder
	@echo "Building for CI with platforms: $(PLATFORMS)..."
	docker buildx build --builder $(BUILDER_NAME) --platform $(PLATFORMS) $(BUILD_ARGS) .

.PHONY: all setup-builder build-arm64 build-amd64 build-all push clean clean-builder ci-build
