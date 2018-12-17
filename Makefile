# docker-nginx-lua build file.
#
# All commands necessary to go from development to release candidate should be here.

CURRENT_DIR = $(shell pwd)
export PATH := $CURRENT_DIR:$(PATH)
export PYTHONPATH := $CURRENT_DIR/api:$(PYTHONPATH)

# -----------------------------------------------------------------------------
# BUILD
# -----------------------------------------------------------------------------
.PHONY: all
all: build

.PHONY: build
build:
	@export IMAGE_NAME=emazzotta/docker-nginx-lua && hooks/build

.PHONY: push
push:
	@docker push emazzotta/docker-nginx-lua

.PHONY: run
run:
	@docker run --rm emazzotta/docker-nginx-lua

