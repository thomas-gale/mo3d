from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota

from memory import UnsafePointer, bitcast
from sys import simdwidthof
from tensor import Tensor
from testing import assert_equal
from time import now, sleep

from mo3d.window.SDL2 import (
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
alias width = 512
alias height = 512
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
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        width,
        height,
        SDL_WINDOW_SHOWN,
    )
    print("Window created")

    if window == UnsafePointer[SDL_Window]():
        print("Failed to create SDL window")
        return

    var renderer = sdl.CreateRenderer(window, -1, 0)

    var display_texture = sdl.CreateTexture(
        renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STREAMING,
        width,
        height,
    )

    @parameter
    fn redraw():
        _ = sdl.RenderClear(renderer)

        # These pixels are in GPU memory - we cant use SIMD as we don't know if SDL2 has aligned them
        var pixels = UnsafePointer[SIMD[DType.uint8, 1]]()
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
        fn draw_row(y: Int):
            @parameter
            fn draw_row_vectorize[simd_width: Int](x: Int):
                var offset = y * manual_pitch + x * channels  # Calculate the correct offset using pitch
                (pixels + offset)[] = 255  # A
                (pixels + offset + 1)[] = 0  # B
                (pixels + offset + 2)[] = (y / (height - 1) * 255.999).cast[
                    DType.uint8
                ]()  # G
                (pixels + offset + 3)[] = (x / (width - 1) * 255.999).cast[
                    DType.uint8
                ]()  # R

            # This vectorize is kinda pointless (using a simd_width of 1). But it's here to show that, if we could ensure the texture is aligned (e.g. use a library ), we can use SIMD here.
            vectorize[draw_row_vectorize, 1](width)

        # We get errors if the number of workers is greater than 1 when inside the main loop
        parallelize[draw_row](height, height)

        sdl.UnlockTexture(display_texture)

        # Convince mojo not to mess with these pointers (which don't even belong to us!) before we've unlocked the texture
        _ = pixels
        _ = pitch

        _ = sdl.RenderCopy(renderer, display_texture, 0, 0)
        _ = sdl.RenderPresent(renderer)

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
        redraw()
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
        str(average_redraw_time / (1000 * 1000)),
        " ms",
    )
    print("Goodbye, mo3d!")
