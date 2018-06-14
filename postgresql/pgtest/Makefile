PULL_REPO=docker-ext-hub-remote.registry.devinfra.ptec
NAME=andriyg/postgres:10
BASE=postgres:10-alpine

up: build
	docker-compose up -d

logs: up
	docker-compose logs -f

build:
	docker-compose build

stop:
	docker-compose stop

rm: stop
	docker-compose rm

pull:
	docker pull $(PULL_REPO)/$(BASE)
	docker tag $(PULL_REPO)/$(BASE) $(BASE)
	docker pull $(PULL_REPO)/adminer
	docker tag $(PULL_REPO)/adminer adminer
