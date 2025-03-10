### Environment Variables

IMAGE_NAME := concatinate-videos-api
GIT_COMMIT := $(shell git rev-parse --short HEAD)

# Default paths for docker-compose and localstack scripts
DOCKER_COMPOSE_FILE := localstack/docker-compose.yml
LOCALSTACK_SCRIPT := ./localstack/scripts/local-infra.sh

### Targets

.PHONY: help
help:
	@cat make.help

.PHONY: all
all: help

.PHONY: install
install:
	npm install

.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(GIT_COMMIT) .

.PHONY: test
test: install build
	npm test

.PHONY: clean
clean: 
	rm -rf node_modules
	rm -rf dist
	rm -rf output

.PHONY: start-api
start-api:
	IMAGE_TAG=$(GIT_COMMIT) docker compose -f $(DOCKER_COMPOSE_FILE) --profile api up

.PHONY: start-api-d
start-api-d:
	IMAGE_TAG=$(GIT_COMMIT) docker compose -f $(DOCKER_COMPOSE_FILE) --profile api up -d

.PHONY: stop-api
stop-api:
	docker compose -f $(DOCKER_COMPOSE_FILE) --profile api stop app

.PHONY: start-localstack
start-localstack:
	$(LOCALSTACK_SCRIPT) start

.PHONY: status-localstack
status-localstack:
	$(LOCALSTACK_SCRIPT) status

.PHONY: stop-localstack
stop-localstack:
	$(LOCALSTACK_SCRIPT) stop

.PHONY: destroy-localstack
destroy-localstack:
	$(LOCALSTACK_SCRIPT) destroy

.PHONY: setup
setup: install build start-api-d start-localstack

.PHONY: teardown
teardown: stop-api stop-localstack

.PHONY: lint
lint: install
	npm run lint

.PHONY: lint-fix
lint-fix: install
	npm run lint:fix

.PHONY: audit
audit: install
	npm audit
