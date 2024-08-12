.PHONY: setup-linux-env setup-mac-env test-sdl-mac install run test package build run-build

setup-linux-env:
	sudo apt update
	sudo apt install -y llvm libsdl2-dev 

setup-mac-env:
	brew install llvm sdl2

install:
	pipx install poetry
	poetry install --no-root
	curl -s https://get.modular.com | sh -
	modular install max

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
