from python import Python
from python.object import PythonObject

from mo3d.SDL import (
    SDL,
    SDL_INIT_VIDEO,
    SDL_WINDOWPOS_CENTERED,
    SDL_WINDOW_SHOWN,
    SDL_PIXELFORMAT_RGBA8888,
    SDL_TEXTUREACCESS_TARGET,
    Event,
    SDL_QUIT,
)


fn main() raises:
    print("Hello, mo3d!")

    var width = 256
    var height = 256

    var sdl = SDL()
    var res_code = sdl.Init(SDL_INIT_VIDEO)
    if res_code != 0:
        print("Failed to initialize SDL")
        return

    var title_ptr = DTypePointer(StringRef("mo3d").data)
    var window = sdl.CreateWindow(
        title_ptr,
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        width,
        height,
        SDL_WINDOW_SHOWN,
    )

    var renderer = sdl.CreateRenderer(window, -1, 0)

    var display = sdl.CreateTexture(
        renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_TARGET,
        width,
        height,
    )

    var target_code = sdl.SetRenderTarget(renderer, display)
    if target_code != 0:
        print("Failed to set render target")
        return

    fn redraw(sdl: SDL) raises:
        var target_code = sdl.SetRenderTarget(renderer, display)
        if target_code != 0:
            print("Failed to set render target")
            return

        for y in range(height):
            for x in range(width):
                var r = 250
                var g = 0
                var b = 0
                _ = sdl.SetRenderDrawColor(renderer, r, g, b, 255)
                _ = sdl.RenderDrawPoint(renderer, y, x)

        _ = sdl.SetRenderTarget(renderer, 0)
        _ = sdl.RenderCopy(renderer, display, 0, 0)
        _ = sdl.RenderPresent(renderer)

    var event = Event()
    var fps = 120
    var running: Bool = True
    while True:
        if not running:
            break

        while sdl.PollEvent(Pointer[Event].address_of(event)) != 0:
            if event.type == SDL_QUIT:
                running = False
                break

        redraw(sdl)
        _ = sdl.Delay(Int32((1000 / fps)))

    sdl.DestroyWindow(window)
    sdl.Quit()

    print("Goodbye, mo3d!")
