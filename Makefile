### Enviroment Variables

IMAGE_NAME := concatinate-videos-api
GIT_COMMIT := $(shell git rev-parse --short HEAD)

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
	IMAGE_TAG=$(GIT_COMMIT) docker compose -f docker-compose.yml --profile api up

.PHONY: start-api-d
start-api-d:
	IMAGE_TAG=$(GIT_COMMIT) docker compose -f docker-compose.yml --profile api up -d

.PHONY: stop-api
stop-api:
	docker compose -f docker-compose.yml --profile api stop app

.PHONY: start-localstack
start-localstack:
	./scripts/local-infra.sh start

.PHONY: status-localstack
status-localstack:
	./scripts/local-infra.sh status

.PHONY: stop-localstack
stop-localstack:
	./scripts/local-infra.sh stop

.PHONY: setup
setup: install start-api-d start-localstack

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