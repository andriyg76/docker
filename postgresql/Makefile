PULL_REPO=docker-ext-hub-remote.registry.devinfra.ptec
NAME=andriyg/postgres:10-alpine
BASE=postgres:10-alpine

build: pull
	docker build -t $(NAME) \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		.

pull:
	docker pull $(PULL_REPO)/$(BASE)
	docker tag $(PULL_REPO)/$(BASE) $(BASE)

