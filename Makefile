# Include variables and help modules
include Makefile.variables
include Makefile.help

# Default target
.DEFAULT_GOAL := help

.PHONY: build run deploy exec log clean test dev-pipeline

# Build the Docker image
build:
	@echo "Building Docker image..."
	@if [ "$(MULTIPLATFORM)" = "true" ]; then \
		docker buildx build --platform $(BUILD_PLATFORMS) -t $(DOCKER_IMAGE) .; \
	else \
		docker build -t $(DOCKER_IMAGE) .; \
	fi
	@echo "Docker image build completed."

# Run Docker container for testing
run: clean
	@echo "Running Docker container..."
	@docker run -d --rm --name $(CONTAINER_NAME) \
		-v $(CURDIR)/$(SRC_PATH):$(CONTAINER_SRC_PATH) -p $(HOST_PORT):$(CONTAINER_PORT) \
		$(DOCKER_IMAGE)
	@$(MAKE) wait-container-ready
	@docker logs -f $(CONTAINER_NAME)

# Deploy application with user-provided code
deploy: clean
	@echo "Deploying Node.js application..."
	@docker run -d --rm --name $(CONTAINER_NAME) \
		-v $(CURDIR)/$(SRC_PATH):$(CONTAINER_SRC_PATH) \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		$(DOCKER_IMAGE)
	@echo "Application is accessible at http://localhost:$(HOST_PORT)"
	@$(MAKE) wait-container-ready

# Execute a command in the running container
exec:
	@docker exec -it $(CONTAINER_NAME) /bin/sh

# View the container logs
log:
	@docker logs $(CONTAINER_NAME) || echo "No running container to log."

# Stop and remove the running container if it exists
clean:
	@docker rm -f $(CONTAINER_NAME) || true

# Wait for container to be ready (using HTTP readiness check)
wait-container-ready:
	@echo "Waiting for the container to be ready..."
	@counter=0; \
	while ! curl -s -o /dev/null -w "%{http_code}" http://localhost:$(HOST_PORT)/health | grep -q "200"; do \
		if [ $$counter -ge 30 ]; then \
			echo "Timeout: Service did not start"; \
			docker logs $(CONTAINER_NAME) || echo "No logs available"; \
			exit 1; \
		fi; \
		echo "Waiting for services to be ready..."; \
		sleep 1; \
		counter=$$((counter + 1)); \
	done
	@echo "Container is ready."

# Run tests
test: build
	@echo "Starting test execution..."
	@docker run -d --name $(CONTAINER_NAME) -v $(CURDIR)/$(SRC_PATH):$(CONTAINER_SRC_PATH) $(DOCKER_IMAGE)
	@$(MAKE) wait-container-ready
	@echo "Running all test scripts in $(SRC_PATH)/tests..."
	@for test_script in $(SRC_PATH)/tests/*.sh; do \
		echo "Running $$(basename $$test_script)..."; \
		docker exec $(CONTAINER_NAME) sh $(CONTAINER_SRC_PATH)/tests/$$(basename $$test_script) || echo "Test $$(basename $$test_script) failed"; \
	done
	@docker rm -f $(CONTAINER_NAME)
	@echo "All tests completed."

# Development pipeline (build and test)
dev-pipeline: build test
	@echo "Development pipeline completed successfully."
