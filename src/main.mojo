from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota

from memory import UnsafePointer
from sys import simdwidthof
from tensor import Tensor
from testing import assert_equal
from time import now, sleep

# from mo3d.window.SDL2 import (
from mo3d.window.SDL3 import (
    SDL_INIT_VIDEO,
    SDL_PIXELFORMAT_RGBA8888,
    SDL_QUIT,
    SDL_TEXTUREACCESS_STREAMING,
    SDL_WINDOWPOS_CENTERED,
    SDL_WINDOW_SHOWN,
    SDL,
    SDL_Rect,
    SDL_Window,
    SDL_Texture,
    Event,
)
from mo3d.math.vec4 import Vec4

alias fps = 120
alias width = 256
alias height = 256
alias channels = Vec4[DType.float32].size

alias float_type = DType.float32


fn main() raises:
    print("Hello, mo3d!")

    var sdl = SDL()
    var res_code = sdl.Init(SDL_INIT_VIDEO)
    if res_code != 0:
        print("Failed to initialize SDL")
        return
    print("SDL initialized")

    var window = sdl.CreateWindow(
        UnsafePointer(StringRef("mo3d").data),
        # SDL_WINDOWPOS_CENTERED, # SDL2
        # SDL_WINDOWPOS_CENTERED, # SDL2
        width,
        height,
        SDL_WINDOW_SHOWN,
    )
    print("Window created")

    if window == UnsafePointer[SDL_Window]():
        print("Failed to create SDL window")
        return

    # SDL2
    # var renderer = sdl.CreateRenderer(window, -1, 0)
    # SDL3
    var renderer = sdl.CreateRenderer(window, 0)

    var display_texture = sdl.CreateTexture(
        renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STREAMING,
        width,
        height,
    )

    fn redraw_texture(sdl: SDL):
        # These pixels are in GPU memory
        var pixels = UnsafePointer[UInt8]()
        var pitch = UnsafePointer[Int32]()
        var lock_code = sdl.LockTexture(
            display_texture, UnsafePointer[SDL_Rect](), pixels, pitch
        )

        if lock_code != 0:
            print("Failed to lock texture:", lock_code)
            print(sdl.get_sdl_error_as_string())
            return

        alias man_pitch = width * 4

        @parameter
        fn draw_row(row: Int):
            for x in range(width):
                var offset = row * man_pitch + x * 4  # Calculate the correct offset using pitch
                (pixels + offset)[] = (x / width * 255).cast[DType.uint8]()
                (pixels + offset + 1)[] = (row / width * 255).cast[
                    DType.uint8
                ]()
                (pixels + offset + 2)[] = (x / width * 255).cast[DType.uint8]()
                (pixels + offset + 3)[] = (row / height * 255).cast[
                    DType.uint8
                ]()
                # (pixels + offset + 3)[] = 255

        # We get errors if the number of workers is greater than 1
        parallelize[draw_row](height, 1)

        sdl.UnlockTexture(display_texture)

    var event = Event()
    var running: Bool = True

    var start_time = now()
    var alpha = 0.1
    var average_redraw_time = 0.0

    print("Window", window)
    print("Renderer", renderer)
    print("Display texture", display_texture)

    while running:
        while sdl.PollEvent(UnsafePointer[Event].address_of(event)) != 0:
            if event.type == SDL_QUIT:
                running = False

        start_time = now()

        # Core rendering code
        _ = sdl.RenderClear(renderer)
        redraw_texture(sdl)
        # SDL2
        # _ = sdl.RenderCopy(renderer, display_texture, 0, 0)
        # SDL3
        _ = sdl.RenderTexture(
            renderer,
            display_texture,
            UnsafePointer[SDL_Rect](),
            UnsafePointer[SDL_Rect](),
        )
        _ = sdl.RenderPresent(renderer)

        average_redraw_time = (1.0 - alpha) * average_redraw_time + alpha * (
            now() - start_time
        )

        _ = sdl.Delay((Float32(1000) / Float32(fps)).cast[DType.int32]())

    sdl.DestroyTexture(display_texture)
    print("Texture destroyed")
    sdl.DestroyRenderer(renderer)
    print("Renderer destroyed")
    sdl.DestroyWindow(window)
    print("Window destroyed")
    sdl.Quit()
    print("SDL quit")

    print(
        "Average redraw time: ",
        str(average_redraw_time / (1024 * 1024)),
        " ms",
    )
    print("Goodbye, mo3d!")
