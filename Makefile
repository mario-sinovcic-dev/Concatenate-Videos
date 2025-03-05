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
	docker compose up --build app

.PHONY: start-api-d
start-api-d:
	docker compose up -d --build app

.PHONY: stop-api
stop-api:
	docker compose stop app

.PHONY: start-localstack
start-localstack:
	./scripts/local-infra.sh start

.PHONY: stop-localstack
stop-localstack:
	./scripts/local-infra.sh stop

.PHONY: setup
setup: install start-api-d start-localstack

.PHONY: lint
lint: install
	npm run lint

.PHONY: audit
audit: install
	npm audit

.PHONY: create-job get-status
create-job:
	@echo "Creating a new video concatenation job"

get-status:
	@echo "Getting job status"
	@echo "Usage: make get-status JOB_ID=<job_id>" 