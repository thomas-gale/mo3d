from python import Python
from python.object import PythonObject

from mo3d.SDL import *


fn main() raises:
    print("Hello, mo3d!")

    var sdl = SDL()

    var res = sdl.Init(0x00000020)
    print(res)

    var window = sdl.CreateWindow(
        DTypePointer(StringRef("mo3d").data),
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        128,
        128,
        SDL_WINDOW_SHOWN,
    )

    var event = Event()

    var running = True
    while running:
        while sdl.PollEvent(Pointer[Event].address_of(event)) != 0:
            if (event.type == SDL_QUIT):
                running = False
                break
        _= sdl.Delay(int(1000 / 120))

    sdl.DestroyWindow(window)
    sdl.Quit()
