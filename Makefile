.PHONY: help
help:
	@cat make.help

.PHONY: all
all: help

.PHONY: install
install:
	npm install

.PHONY: test
test: install
	npm test

.PHONY: clean
clean: 
	rm -rf node_modules
	rm -rf dist
	rm -rf output

.PHONY: start-api
start-api:
	docker compose -f docker-compose.api.yml up --build app

.PHONY: start-api-d
start-api-d:
	docker compose -f docker-compose.api.yml up -d --build app

.PHONY: stop-api
stop-api:
	docker compose -f docker-compose.api.yml stop app

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