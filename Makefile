SHELL := /usr/bin/env bash

EXTENSION := src/context.bash

TARGET_DIR := target
TARGET_TESTS_DIR := $(TARGET_DIR)/tests

TESTS_DIR := tests
TESTS_SCRIPTS_DIR := $(TESTS_DIR)/scripts

PGP_KEY := $(TESTS_DIR)/masterkey.asc
PGP_KEY_ID := 2C752423906F4CE73091C2077B18C1616AAA9C35

B := \033[1m
N := \033[m

.PHONY: all test lint test-get_context test-main

all:
	@printf "Available Targets:\n\n"
	@printf "$(B)test$(N):\t\t\trun all the \"test-*\" targets.\n"
	@printf "$(B)lint$(N):\t\t\tlint the extension script.\n"
	@printf "$(B)test-get_context$(N):\trun the tests for the \"get_context()\" function.\n"

test: lint test-get_context test-main

lint:
	shellcheck $(EXTENSION)
	grep '.\{81\}' $(EXTENSION) 1>/dev/null 2>&1 && exit 1 || exit 0
	shfmt -i 2 -bn -ci -d $(EXTENSION)

test-get_context:
	TARGET_TESTS_DIR=$(TARGET_TESTS_DIR) EXTENSION=$(EXTENSION) \
			   $(SHELL) $(TESTS_SCRIPTS_DIR)/get_context.bash
test-main:
	TARGET_TESTS_DIR=$(TARGET_TESTS_DIR) EXTENSION=$(EXTENSION) \
					PGP_KEY=$(PGP_KEY) PGP_KEY_ID=$(PGP_KEY_ID) \
					$(SHELL) $(TESTS_SCRIPTS_DIR)/context.bash
