# Add all targets to PHONY by default
NON_PHONY_TARGETS := .PHONY
PHONY_TARGETS := $(filter-out $(NON_PHONY_TARGETS), $(shell grep '^[.a-zA-Z0-9]*:' Makefile | sed 's/:.*//'))
.PHONY: $(PHONY_TARGETS)

run:
	iex -S mix

solve:
	mix run -e "Travel.display_itinerary()"

build:
	mix do deps.get + compile

test:
	mix test --warnings-as-errors $(ARGS)

# for testing with IEx.pry statements
pry_test:
	iex -S mix test --trace $(ARGS)

format:
	mix format

credo:
	mix credo --strict

dialyzer:
	mix dialyzer

ci: format credo dialyzer test
