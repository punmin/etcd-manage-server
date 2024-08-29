UI_MODULE_REPLACE_COMMAND ?= \	github.com/punmin/etcd-manage-ui/tpls => ./tpls

default:
	@echo 'Usage of make: [ build | linux_build | linux_build_with_local_ui_module | windows_build | docker_build | docker_build_with_local_ui_module | docker_run | clean ]'

replace_ui_module_with_local_path: 
	sed -i "/replace/a $(UI_MODULE_REPLACE_COMMAND)" go.mod;

build_ui_module:
	cd ..; \
	git clone https://github.com/punmin/etcd-manage-ui.git; \
	cd etcd-manage-ui; \
	make docker_build; \
	cp -rf tpls $(CURDIR)/;

build: 
	@go build -o ./bin/ems ./

linux_build: 
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./bin/ems ./

linux_build_with_local_ui_module: build_ui_module replace_ui_module_with_local_path
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./bin/ems ./

windows_build: 
	@CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o ./bin/ems.exe ./

docker_build: 
	docker build -t etcd-manage .

docker_build_with_local_ui_module: build_ui_module
	docker build --build-arg LOCAL_UI_MODULE=true -t etcd-manage .;

docker_run: docker_build
	docker-compose up --force-recreate

run: build
	@./bin/ems

install: build
	@mv ./bin/ems $(GOPATH)/bin/ems

clean: 
	@rm -f ./bin/ems*
	@rm -f ./bin/logs/*

.PHONY: default build linux_build linux_build_with_local_ui_module windows_build docker_build docker_build_with_local_ui_module docker_run clean
