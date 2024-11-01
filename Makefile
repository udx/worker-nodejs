# Include configuration variables and help
include Makefile.variables
include Makefile.help

.DEFAULT_GOAL := help

.PHONY: build run deploy exec log clean test help

# Docker Commands for Reusability
DOCKER_RUN := docker run --rm --name $(CONTAINER_NAME) -e NODE_ENV=$(NODE_ENV) -p $(HOST_PORT):$(CONTAINER_PORT) -v $(CURDIR):/usr/src/app
DOCKER_EXEC := docker exec -it $(CONTAINER_NAME)
DOCKER_CLEAN := docker rm -f $(CONTAINER_NAME) || true

build: 
	@echo "Building Docker image..."
	@docker build $(if $(NO_CACHE),--no-cache) -t $(DOCKER_IMAGE) .
	@echo "Docker image build completed."

# Ensure clean start by stopping and removing any existing container with the same name
run: clean
	@echo "Running Docker container..."
	@$(DOCKER_RUN) $(if $(DETACHED),-d,-it) $(DOCKER_IMAGE)
	@echo "Container started successfully."

exec:
	@echo "Executing command in Docker container..."
	@$(DOCKER_EXEC) $(if $(CMD),$(CMD),/bin/sh)

log:
	@echo "Viewing Docker container logs..."
	@docker logs $(CONTAINER_NAME)

clean:
	@echo "Stopping and removing Docker container if it exists..."
	@$(DOCKER_CLEAN)

# Run tests with test-specific environment, and clean up container after tests
test: clean
	@echo "Running tests with NODE_ENV=test..."
	@EXIT_CODE=0; \
	docker run --name $(CONTAINER_NAME) --rm -e NODE_ENV=test -v $(CURDIR):/usr/src/app $(DOCKER_IMAGE) /bin/sh -c '\
		for t in /usr/src/app/src/tests/*.sh; do \
			if [ -f "$$t" ]; then \
				echo "Running test $$t..."; \
				sh $$t || { echo "Test $$t failed"; EXIT_CODE=1; }; \
			else \
				echo "No test scripts found in /usr/src/app/src/tests."; \
				EXIT_CODE=1; \
			fi; \
		done; \
		exit $$EXIT_CODE' || EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -eq 0 ]; then \
		echo "All tests passed."; \
	else \
		echo "Some tests failed."; \
	fi; \
	exit $$EXIT_CODE

deploy: clean
	@echo "Deploying application..."
	@$(DOCKER_RUN) -d $(DOCKER_IMAGE)
	@echo "Application deployed and accessible at http://localhost:$(HOST_PORT)"
