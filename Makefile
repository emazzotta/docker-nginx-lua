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
	@docker compose build

.PHONY: run
run:
	@echo "Running at http://localhost:8080"
	@docker compose up
