NAME=wikicr

all: deps_opt build

run:
	crystal run src/$(NAME).cr --error-trace
build:
	crystal build src/$(NAME).cr --stats --error-trace
release:
	crystal build src/$(NAME).cr --stats --release
test:
	crystal spec --error-trace
deps:
	shards install
deps_update:
	shards update
deps_opt:
	@[ -d lib/ ] || make deps
doc:
	crystal docs
clean:
	rm $(NAME)
format:
	crystal tool format

.PHONY: all run build release test deps deps_update clean doc format
