.PHONY: all build clean install start test

build:
	env MIX_ENV=prod mix escript.build

clean:
	mix clean
	rm -rf ./bin

install:
	cp ./bin/mgmt /usr/local/bin
	cp ./scripts/mgmt_askpass /usr/local/bin

start:
	iex -S mix

test:
	mix test
