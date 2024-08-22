from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota

from memory import UnsafePointer
from sys import simdwidthof
from tensor import Tensor
from testing import assert_equal
from time import now, sleep

from mo3d.window.SDL2 import (
    # from mo3d.window.SDL3 import (
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
alias width = 1024
alias height = 768
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
        SDL_WINDOWPOS_CENTERED,  # SDL2
        SDL_WINDOWPOS_CENTERED,  # SDL2
        width,
        height,
        SDL_WINDOW_SHOWN,
    )
    print("Window created")

    if window == UnsafePointer[SDL_Window]():
        print("Failed to create SDL window")
        return

    # SDL2
    var renderer = sdl.CreateRenderer(window, -1, 0)
    # SDL3
    # var renderer = sdl.CreateRenderer(window, 0)

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
        # This value doesn't seem to be at a sensible address - 0x400 (Is this SDL2's null pointer?)
        var pitch = UnsafePointer[Int32]()
        # Manually set the pitch to the width * 4 (4 channels)
        alias channels = 4
        alias manual_pitch = width * channels
        var lock_code = sdl.LockTexture(
            display_texture, UnsafePointer[SDL_Rect](), pixels, pitch
        )

        if lock_code != 0:
            print("Failed to lock texture:", lock_code)
            print(sdl.get_sdl_error_as_string())
            return


        @parameter
        fn draw_row(row: Int):
            for x in range(width):
                var offset = row * manual_pitch + x * channels # Calculate the correct offset using pitch
                # Hack, the pixel orders are not as expected ^^ TODO check above format.
                (pixels + offset)[] = 255  # A
                (pixels + offset + 1)[] = 0  # B
                (pixels + offset + 2)[] = (row / (height - 1) * 255.999).cast[
                    DType.uint8
                ]()  # G
                (pixels + offset + 3)[] = (x / (width - 1) * 255.999).cast[
                    DType.uint8
                ]()  # R
            # Simulate work on this worker
            # sleep(0.001)

        # We get errors if the number of workers is greater than 1 when inside the main loop
        parallelize[draw_row](height, height)
        # parallelize[draw_row](height, 1)

        sdl.UnlockTexture(display_texture)

        # Convince mojo not to free these pointers (which don't even belong to us!) prematurely before we've unlocked the texture
        _ = pixels
        _ = pitch

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
        _ = sdl.RenderCopy(renderer, display_texture, 0, 0)
        # SDL3
        # _ = sdl.RenderTexture(
        #     renderer,
        #     display_texture,
        #     UnsafePointer[SDL_Rect](),
        #     UnsafePointer[SDL_Rect](),
        # )
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
