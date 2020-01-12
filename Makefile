.PHONY: all build clean install start test

build:
	env MIX_ENV=prod mix escript.build

clean:
	mix clean

install:
	cp ./bin/mgmt /usr/local/bin

start:
	iex -S mix

test:
	mix test
