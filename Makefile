.PHONY: all build clean install test

build:
	mix escript.build

clean:
	mix clean

install:
	cp ./bin/mgmt /usr/local/bin

test:
	mix test
