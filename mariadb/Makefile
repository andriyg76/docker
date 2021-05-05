REPO=andriyg
NAME=mariadb_with_dump

build: 
	docker build -t $(REPO)/$(NAME):latest \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		.

push: build
	docker push $(REPO)/$(NAME)

build5: 
	docker build -t $(REPO)/$(NAME):10.5 \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		--file 10.5.dockerfile \
		.

push5: build5
	docker push $(REPO)/$(NAME):10.5

