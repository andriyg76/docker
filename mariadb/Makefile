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

build2: 
	docker build -t $(REPO)/$(NAME):10.2 \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		--file 10.2.dockerfile \
		.

push2: build2
	docker push $(REPO)/$(NAME):10.2

build3: 
	docker build -t $(REPO)/$(NAME):10.3 \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		--file 10.3.dockerfile \
		.

push3: build3
	docker push $(REPO)/$(NAME):10.3

build4: 
	docker build -t $(REPO)/$(NAME):10.4 \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		--file 10.4.dockerfile \
		.

push4: build4
	docker push $(REPO)/$(NAME):10.4

build5: 
	docker build -t $(REPO)/$(NAME):10.5 \
		--build-arg http_proxy=$(http_proxy) \
		--build-arg https_proxy=$(http_proxy) \
		--build-arg no_proxy=$(no_proxy) \
		--file 10.5.dockerfile \
		.

push5: build5
	docker push $(REPO)/$(NAME):10.5

