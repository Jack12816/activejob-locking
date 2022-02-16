 MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.PHONY: test

GEMFILES_DIR ?= gemfiles

BUNDLE ?= bundle
ECHO ?= echo
NPROC ?= nproc
PRINTF ?= printf
RESET ?= reset
SED ?= sed
TR ?= tr

# Dynamic recipes
GEMFILES := $(subst .gemfile,,$(notdir $(wildcard $(GEMFILES_DIR)/*.gemfile)))
GEMFILES_DASHED := $(shell $(PRINTF) '$(GEMFILES)' | $(TR) -c '[:alnum:] ' '-')
TEST_RECIPES := $(GEMFILES_DASHED:%=test-%)
TEST_DEBUG_RECIPES := $(GEMFILES_DASHED:%=test-%-debug)

all:
	# ActiveJob Locking
	#
	# install                 Install the dependencies
	#
	# # Run tests
	#
	@$(foreach recipe,$(TEST_RECIPES),$(ECHO) '#   $(recipe)';)
	#
	# # Run tests with debugging outputs
	#
	@$(foreach recipe,$(TEST_DEBUG_RECIPES),$(ECHO) '#   $(recipe)';)

install:
	@$(BUNDLE) check || $(BUNDLE) install --jobs $(shell $(NPROC))

$(TEST_RECIPES): GEMFILE_INPUT = $(@:test-%=%)
$(TEST_RECIPES):
	@$(eval GEMFILE := $(shell $(PRINTF) '$(GEMFILE_INPUT)' \
		| $(SED) 's/\([[:digit:]]\+\)\-/\1./g'))
	# Run tests with $(GEMFILE) Gemfile
	@$(BUNDLE) exec appraisal $(GEMFILE) rake test

$(TEST_DEBUG_RECIPES): RECIPE = $(@:%-debug=%)
$(TEST_DEBUG_RECIPES):
	@$(RESET)
	@DEBUG=true $(MAKE) --no-print-directory $(RECIPE)
