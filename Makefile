.PHONY: setup-linux-env setup-mac-env test-sdl-mac install run test package build run-build

install-magic:
	curl -ssL https://magic.modular.com/4d5956ea-5c83-4315-b56b-dd4ff6af8de8 | bash

run: 
	magic run mojo run src/main.mojo

package:
	mkdir -p bin
	magic run mojo package src/mo3d -o bin/mo3d.mojopkg
	# To allow test in vscode intellisense
	cp bin/mo3d.mojopkg test/mo3d/mo3d.mojopkg

test: package
	magic run mojo test 

