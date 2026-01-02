SHELL := /bin/bash

.PHONY: init build up down status keys export compose-build compose-up

init:
	@./bin/hypernode init

build:
	@./bin/hypernode build

up:
	@./bin/hypernode up

down:
	@./bin/hypernode down

status:
	@./bin/hypernode status

keys:
	@./bin/hypernode keys

export:
	@./bin/hypernode export

compose-build:
	@docker compose -f docker-compose.yml build --no-cache

compose-up:
	@docker compose -f docker-compose.yml up -d

