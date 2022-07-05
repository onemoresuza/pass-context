SHELL := /usr/bin/env bash
EXTENSION := src/context.bash
TARGET_DIR := target
TARGET_TESTS_DIR := $(TARGET_DIR)/tests
TESTS_DIR := tests
B := \033[1m
N := \033[m

.PHONY: all test test-rperr test-get_context lint

all:
	@printf "Available Targets:\n\n"
	@printf "$(B)test$(N):\t\t\trun all the \"test-*\" targets.\n"
	@printf "$(B)lint$(N):\t\t\tlint the extension script.\n"
	@printf "$(B)test-get_context$(N):\trun the tests for the \"get_context()\" function.\n"

test: lint test-rperr test-get_context

lint:
	shellcheck $(EXTENSION)
	grep '.\{81\}' $(EXTENSION) 1>/dev/null 2>&1 && exit 1 || exit 0
	shfmt -i 2 -bn -ci -d $(EXTENSION)

test-get_context:
	TARGET_TESTS_DIR=$(TARGET_TESTS_DIR) EXTENSION=$(EXTENSION) \
			   $(SHELL) $(TESTS_DIR)/get_context.bash
