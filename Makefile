SHELL := /usr/bin/env bash
EXTENSION := src/context.bash
TESTS_DIR := tests
B := \033[1m
N := \033[m

.PHONY: all test test-rperr

all:
	@printf "Available Targets:\n\n"
	@printf "$(B)test$(N):\t\t\trun all the \"test-*\" targets.\n"
	@printf "$(B)test-rperr$(N):\t\trun the tests for the \"rperr()\" function.\n"
	@printf "$(B)test-get_context$(N):\trun the tests for the \"get_context()\" function.\n"

test: test-rperr

test-rperr:
	EXTENSION=$(EXTENSION) $(SHELL) $(TESTS_DIR)/rperr.bash

test-get_context:
	EXTENSION=$(EXTENSION) $(SHELL) $(TESTS_DIR)/get_context.bash
