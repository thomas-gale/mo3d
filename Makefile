.PHONY: setup-linux-env setup-mac-env test-sdl-mac install run test package build run-build

setup-linux-env:
	sudo apt update
	sudo apt install -y llvm libsdl2-dev 

setup-linux-env-sdl3:
	# Deps
	sudo apt update
	sudo apt install -y build-essential git make \
	pkg-config cmake ninja-build gnome-desktop-testing libasound2-dev libpulse-dev \
	libaudio-dev libjack-dev libsndio-dev libx11-dev libxext-dev \
	libxrandr-dev libxcursor-dev libxfixes-dev libxi-dev libxss-dev \
	libxkbcommon-dev libdrm-dev libgbm-dev libgl1-mesa-dev libgles2-mesa-dev \
	libegl1-mesa-dev libdbus-1-dev libibus-1.0-dev libudev-dev fcitx-libs-dev \
	libpipewire-0.3-dev libwayland-dev libdecor-0-dev

	# Get SDL3 source code
	git clone https://github.com/libsdl-org/SDL.git
	cd SDL

	# Build SDL3
	mkdir build
	cd build
	cmake .. -DCMAKE_BUILD_TYPE=Release
	make 

	# System wide install
	sudo make install

setup-mac-env:
	brew install llvm sdl2

install:
	curl -s https://get.modular.com | sh -s -- ce42d51f-fb3c-4b98-bd05-9dcc020921b2
	modular auth
	modular install nightly/max

install-magic:
	curl -ssL https://modul.ar/magic-alpha | bash


run: 
	# magic run mojo run src/main.mojo
	mojo run src/main.mojo

package:
	mkdir -p bin
	# magic run mojo package src/mo3d -o bin/mo3d.mojopkg
	mojo package src/mo3d -o bin/mo3d.mojopkg
	# To allow test in vscode intellisense
	cp bin/mo3d.mojopkg test/mo3d/mo3d.mojopkg

test: package
	# magic run mojo test 
	mojo test

build:
	mkdir -p bin
	# magic run mojo build src/main.mojo -o bin/mo3d
	mojo build src/main.mojo -o bin/mo3d

run-build: build
	bin/mo3d
