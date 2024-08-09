.PHONY: install run test

install-sdl-mac:
	brew install sdl2


test-sdl-mac:
	clang++ -std=c++17 -I/opt/homebrew/include/SDL2 -L/opt/homebrew/lib -lSDL2 test_sdl.cpp -o test_sdl
	./test_sdl

install:
	pipx install poetry
	poetry install --no-root
	curl -s https://get.modular.com | sh -
	modular install mojo

run: 
	poetry run mojo run src/main.mojo

test: 
	poetry run mojo test -I src test

package:
	mkdir -p bin
	poetry run mojo package src/mo3d -o bin/mo3d.mojopkg

build:
	mkdir -p bin
	poetry run mojo build src/main.mojo -o bin/mo3d

run-build:
	bin/mo3d

build-test:
	mkdir -p bin
	poetry run mojo build src/tests.mojo -o bin/mo3dtest

run-build-test:
	bin/mo3dtest
