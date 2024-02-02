# docker-nginx-lua build file.
#
# All commands necessary to go from development to release candidate should be here.

ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# -----------------------------------------------------------------------------
# BUILD
# -----------------------------------------------------------------------------
.PHONY: all
all: build

.PHONY: build
build:
	@docker build -t emazzotta/docker-nginx-lua .

.PHONY: push
push:
	@docker push emazzotta/docker-nginx-lua

.PHONY: run
run:
	@docker run --rm emazzotta/docker-nginx-lua
