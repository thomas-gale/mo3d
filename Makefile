.PHONY: setup-linux-env setup-mac-env test-sdl-mac install run test package build run-build

setup-linux-env:
	sudo apt update
	sudo apt install -y llvm libsdl2-dev 

setup-mac-env:
	brew install llvm sdl2

install:
	pipx install poetry
	poetry install --no-root
	curl -s https://get.modular.com | sh -s -- ce42d51f-fb3c-4b98-bd05-9dcc020921b2
	modular install max

install-nightly:
	pipx install poetry
	poetry install --no-root
	curl -s https://get.modular.com | sh -s -- ce42d51f-fb3c-4b98-bd05-9dcc020921b2
	modular auth
	modular install nightly/max

install-magic:
	curl -ssL https://modul.ar/magic-alpha | bash

run: 
	poetry run mojo run src/main.mojo

package:
	mkdir -p bin
	poetry run mojo package src/mo3d -o bin/mo3d.mojopkg
	# To allow test in vscode intellisense
	cp bin/mo3d.mojopkg test/mo3d/mo3d.mojopkg

test: package
	poetry run mojo test 

build:
	mkdir -p bin
	poetry run mojo build src/main.mojo -o bin/mo3d

run-build: build
	bin/mo3d
