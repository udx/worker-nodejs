# Include variables and help modules
include Makefile.variables
include Makefile.help

# Default target
.DEFAULT_GOAL := help

.PHONY: build run deploy run-it run-debug exec log clean test wait-container-ready dev-pipeline help

# Build the Docker image ## Build the Docker image
build:
	@echo "Building Docker image..."
	@if [ "$(MULTIPLATFORM)" = "true" ]; then \
		echo "Building Docker image for multiple platforms..."; \
		docker buildx build --platform $(BUILD_PLATFORMS) -t $(DOCKER_IMAGE) $(if $(NO_CACHE),--no-cache) .; \
	else \
		echo "Building Docker image for the local platform..."; \
		docker build -t $(DOCKER_IMAGE) $(if $(NO_CACHE),--no-cache) .; \
	fi
	@echo "Docker image build completed."

# Run Docker container (detached by default) ## Run the Docker container with the default app (detached by default)
run: clean
	@echo "Running Docker container..."
	@docker run $(if $(DETACHED),-d,-it) --rm --name $(CONTAINER_NAME) \
		-e NODE_ENV=$(NODE_ENV) \
		-v $(CURDIR)/$(SRC_PATH):$(CONTAINER_SRC_PATH) -p $(HOST_PORT):$(CONTAINER_PORT) \
		$(DOCKER_IMAGE) $(if $(CMD),$(CMD),)
	@if [ "$(DETACHED)" = "true" ]; then \
		$(MAKE) wait-container-ready; \
		$(MAKE) log; \
	fi

# Deploy application (production mode) ## Deploy application in production mode
deploy: clean
	@echo "Deploying application..."
	@docker run -d --rm --name $(CONTAINER_NAME) \
		-v $(CURDIR)/$(SRC_PATH):/usr/src/app \
		-p $(HOST_PORT):8080 \
		$(DOCKER_IMAGE)
	@echo "Application is accessible at http://localhost:$(HOST_PORT)"
	@$(MAKE) wait-container-ready

# Run Docker container in interactive mode ## Run Docker container interactively
run-it: CMD=/bin/sh
run-it: DETACHED=false
run-it: run

# Run Docker container in debug mode ## Run Docker container in debug mode with shell access
run-debug: CMD=/bin/sh
run-debug: DETACHED=false
run-debug: run

# Execute a command in the running container ## Execute a command inside the running container
exec:
	@echo "Executing command in Docker container..."
	@docker exec -it $(CONTAINER_NAME) $(if $(CMD),$(CMD),/bin/sh)

# View the container logs ## View logs of the running container
log:
	@echo "Viewing Docker container logs..."
	@docker logs $(CONTAINER_NAME) || echo "No running container to log."

# Stop and remove the running container if it exists ## Stop and remove the running container
clean:
	@echo "Stopping and removing Docker container if it exists..."
	@docker rm -f $(CONTAINER_NAME) || true

# Wait for container to be ready using PM2 readiness check ## Wait until PM2 services in the container are ready
wait-container-ready:
	@echo "Waiting for container and PM2 services to be ready..."
	@counter=0; \
	while docker ps -q -f name=$(CONTAINER_NAME) | grep -q .; do \
		if $(MAKE) exec CMD="pm2 list" | grep -q "online"; then \
			echo "PM2 services are ready."; \
			exit 0; \
		elif [ $$counter -ge 30 ]; then \
			echo "Timeout: PM2 services did not start as expected."; \
			echo "Displaying container logs for troubleshooting:"; \
			$(MAKE) log; \
			exit 1; \
		fi; \
		echo "Waiting for PM2 services to be ready..."; \
		sleep 2; \
		counter=$$((counter + 1)); \
	done
	echo "Container stopped unexpectedly."
	$(MAKE) log
	exit 1

# Run tests ## Run all tests or a specific test script if TEST_SCRIPT is provided
test: build run
	@if [ -z "$(TEST_SCRIPT)" ]; then \
		echo "Executing all test scripts..."; \
		for test_script in $(SRC_PATH)/tests/*.sh; do \
			echo "Running $$(basename $$test_script)..."; \
			$(MAKE) exec CMD="sh $(CONTAINER_SRC_PATH)/tests/$$(basename $$test_script)" || echo "Test $$(basename $$test_script) failed"; \
		done; \
	else \
		echo "Running test script $(TEST_SCRIPT)..."; \
		$(MAKE) exec CMD="sh $(CONTAINER_SRC_PATH)/tests/$(TEST_SCRIPT)"; \
	fi
	@$(MAKE) clean
	@echo "All tests completed."

# Development pipeline ## Run the full development pipeline, including build and tests
dev-pipeline: test
	@echo "Development pipeline completed successfully."
