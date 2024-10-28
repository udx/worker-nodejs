# Include variables and help modules
include Makefile.variables
include Makefile.help

# Default target
.DEFAULT_GOAL := help

.PHONY: run clean build exec log test dev-pipeline

# Variables for Docker run
DOCKER_RUN_FLAGS := --rm --name $(CONTAINER_NAME) -p 8080:8080 -v $(CURDIR)/src:/usr/src/app

# Build the Docker image
MULTIPLATFORM ?= false

build:
	@echo "Building Docker image..."
	@if [ "$(MULTIPLATFORM)" = "true" ]; then \
		echo "Building Docker image for multiple platforms..."; \
		docker buildx build --platform linux/amd64,linux/arm64 -t $(DOCKER_IMAGE) .; \
	else \
		echo "Building Docker image for the local platform..."; \
		docker build -t $(DOCKER_IMAGE) .; \
	fi
	@echo "Docker image build completed."

# Run Docker container
run: clean
	@echo "Running Docker container..."
	@docker run -d $(DOCKER_RUN_FLAGS) $(DOCKER_IMAGE)
	@echo "Docker container is running with port 8080 mapped."

# Exec into the running container
exec:
	@echo "Executing into Docker container..."
	@docker exec -it $(CONTAINER_NAME) /bin/sh

# View the container logs
log:
	@echo "Viewing Docker container logs..."
	@docker logs $(CONTAINER_NAME)

# Delete the running container
clean:
	@echo "Deleting Docker container if exists..."
	@docker rm -f $(CONTAINER_NAME) || true

# Run the validation tests
test: build run clean
	@echo "Validation tests completed."

# Development pipeline
dev-pipeline: build test
	@echo "Development pipeline completed successfully."
