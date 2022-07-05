SHELL := /usr/bin/env bash
EXTENSION := src/context.bash
TESTS_DIR := tests
B := \033[1m
N := \033[m

.PHONY: all test test-rperr

all:
	@printf "Available Targets:\n\n"
	@printf "$(B)test$(N): run all the \"test-*\" targets.\n"
	@printf "$(B)test-rperr$(N): run the tests for the \"rperr()\" function.\n"

test: test-rperr

test-rperr:
	EXTENSION=$(EXTENSION) $(SHELL) $(TESTS_DIR)/rperr.bash
