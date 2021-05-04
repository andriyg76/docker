REPO=andriyg
FULL_NAME=$(NAME):latest
NAME=mysql_with_dump

build: 
	docker build -t $(REPO)/$(FULL_NAME) \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		.

push: build
	docker push $(REPO)/$(FULL_NAME)

build5.5:
	docker build -t $(REPO)/$(NAME):5.5 \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		--file mysql.5.5.docker \
		.

push: build5.5
	docker push $(REPO)/$(NAME):5.5

build8:
	docker build -t $(REPO)/$(NAME):8 \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		--file mysql.8.docker \
		.

push8: build8
	docker push $(REPO)/$(NAME):8
