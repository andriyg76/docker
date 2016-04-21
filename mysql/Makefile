REPO=andriyg
NAME=mysql_with_dump

build: 
	docker build -t $(REPO)/$(NAME) \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		.
