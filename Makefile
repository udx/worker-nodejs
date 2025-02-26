# Include variables and help modules
include Makefile.variables
include Makefile.help

# Default target
.DEFAULT_GOAL := help

# Phony targets ensure Make doesn't get confused by filenames
.PHONY: build run deploy run-it clean exec log test dev-pipeline run-all-tests wait-container-ready

# Docker Commands for Reusability
DOCKER_RUN_BASE := docker run --rm --name $(CONTAINER_NAME) \
    -e NODE_ENV=$(NODE_ENV) \
    -p $(HOST_PORT):$(CONTAINER_PORT)

# Determine if we should run in detached mode or interactively
ifeq ($(INTERACTIVE),true)
    DOCKER_RUN := $(DOCKER_RUN_BASE) -it --entrypoint $(CMD)
else
    DOCKER_RUN := $(DOCKER_RUN_BASE) -d
endif

DOCKER_EXEC := docker exec -it $(CONTAINER_NAME)
DOCKER_CLEAN := docker rm -f $(CONTAINER_NAME) || true

# Build the Docker image with multi-platform support
build:
	@echo "Building Docker image..."
	@if [ "$(MULTIPLATFORM)" = "true" ]; then \
		echo "Building Docker image for multiple platforms..."; \
		docker buildx build --platform $(BUILD_PLATFORMS) -t $(DOCKER_IMAGE) .; \
	else \
		echo "Building Docker image for the local platform..."; \
		docker build -t $(DOCKER_IMAGE) .; \
	fi
	@echo "Docker image build completed."

# Run Docker container in specified environment with readiness check
run: clean
	@echo "Running Docker container..."
	@$(DOCKER_RUN) $(DOCKER_IMAGE)
	@$(MAKE) wait-container-ready
	@echo "Container started successfully."

# Run Docker container in interactive mode
run-it:
	$(MAKE) run INTERACTIVE=true CMD="/bin/bash"

# Execute a command inside the running container
exec:
	@echo "Executing command in Docker container..."
	@$(DOCKER_EXEC) $(if $(CMD),$(CMD),/bin/bash)

# View logs of the running container
log:
	@echo "Viewing Docker container logs..."
	@docker logs $(CONTAINER_NAME) || echo "No running container to log."

# Clean up by stopping and removing the container if it exists
clean:
	@echo "Stopping and removing Docker container if it exists..."
	@$(DOCKER_CLEAN)

# Wait for container to be ready by checking application readiness
wait-container-ready:
	@echo "Waiting for the container to be ready..."
	@counter=0; \
	while ! curl -s -o /dev/null -w "%{http_code}" http://localhost:$(HOST_PORT) | grep -q "200"; do \
		if [ $$counter -ge 30 ]; then \
			echo "Timeout: Application did not start"; \
			exit 1; \
		fi; \
		echo "Waiting for application to be ready..."; \
		sleep 1; \
		counter=$$((counter + 1)); \
	done
	@echo "Container is ready."

# Run all tests in the tests directory
run-all-tests:
	@echo "Running all tests in Docker container..."
	@docker run --rm \
		-v $(PWD)/src/tests:/usr/src/app/tests \
		-v $(PWD)/src/examples/simple-server/index.js:/usr/src/app/index.js \
		-v $(PWD)/src/examples/simple-server/.config/worker/services.yaml:/home/udx/.config/worker/services.yaml \
		-e NODE_ENV=test \
		$(DOCKER_IMAGE) \
		/bin/sh -c 'cd /usr/src/app/tests && for test_script in *.sh; do \
			echo "Running $$test_script..."; \
			sh ./$$test_script || { echo "Test $$test_script failed"; exit 1; }; \
		done'

# Run validation tests (build and run-all-tests)
test: build run-all-tests
	@echo "Validation tests completed."

# Development pipeline (build and test)
dev-pipeline: build test
	@echo "Development pipeline completed successfully."
