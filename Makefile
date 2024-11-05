# Include variables and help modules
include Makefile.variables
include Makefile.help

# Default target
.DEFAULT_GOAL := help

.PHONY: build run deploy run-it clean exec log test dev-pipeline run-test run-all-tests wait-container-ready

# Docker Commands for Reusability
DOCKER_RUN := docker run --rm --name $(CONTAINER_NAME) \
    -e NODE_ENV=$(NODE_ENV) \
    -e LOG_DIR=$(LOG_DIR) \
    -e WATCH_MODE=$(WATCH_MODE) \
    -p $(HOST_PORT):$(CONTAINER_PORT) \
    -v $(CURDIR):/usr/src/app

DOCKER_RUN_DETACHED := $(DOCKER_RUN) -d $(DOCKER_IMAGE)
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
	@$(DOCKER_RUN) $(if $(DETACHED),-d,-it) $(DOCKER_IMAGE)
	@$(MAKE) --no-print-directory wait-container-ready
	@echo "Container started successfully."

# Deploy application in production mode with readiness check
deploy: clean
	@echo "Deploying application in production mode..."
	@NODE_ENV=production $(DOCKER_RUN_DETACHED)
	@$(MAKE) --no-print-directory wait-container-ready
	@echo "Application deployed and accessible at http://localhost:$(HOST_PORT)"

# Run Docker container in interactive mode
run-it:
	@$(MAKE) --no-print-directory run INTERACTIVE=true CMD="/bin/sh"

# Execute a command inside the running container
exec:
	@echo "Executing command in Docker container..."
	@$(DOCKER_EXEC) $(if $(CMD),$(CMD),/bin/sh)

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
			$(MAKE) --no-print-directory log || echo "No logs available"; \
			exit 1; \
		fi; \
		echo "Waiting for application to be ready..."; \
		sleep 1; \
		counter=$$((counter + 1)); \
	done
	@echo "Container is ready."

# Run a specific test script (specified by TEST_SCRIPT)
run-test: clean
	@echo "Running test script $(TEST_SCRIPT) in test environment..."
	@NODE_ENV=test $(DOCKER_RUN_DETACHED)
	@$(MAKE) --no-print-directory wait-container-ready
	@if [ -z "$(TEST_SCRIPT)" ]; then \
		echo "Error: TEST_SCRIPT variable is not set. Specify a script to run, e.g., make run-test TEST_SCRIPT=example.sh"; \
		exit 1; \
	fi
	@$(DOCKER_EXEC) sh $(CONTAINER_SRC_PATH)/tests/$(TEST_SCRIPT) || echo "Test $(TEST_SCRIPT) failed"
	@$(DOCKER_CLEAN)

# Run all tests in the tests directory with test environment
run-all-tests: clean
	@echo "Starting Docker container for test execution in test environment..."
	@NODE_ENV=test $(DOCKER_RUN_DETACHED)
	@$(MAKE) --no-print-directory wait-container-ready
	@echo "Executing all test scripts..."
	@for test_script in $(SRC_PATH)/tests/*.sh; do \
		echo "Running $$(basename $$test_script)..."; \
		$(DOCKER_EXEC) sh $(CONTAINER_SRC_PATH)/tests/$$(basename $$test_script) || echo "Test $$(basename $$test_script) failed"; \
	done
	@$(MAKE) --no-print-directory log
	@$(DOCKER_CLEAN)
	@echo "All tests completed."

# Run validation tests (build and run-all-tests)
test: build run-all-tests
	@echo "Validation tests completed."

# Development pipeline (build and test)
dev-pipeline: build test
	@echo "Development pipeline completed successfully."
