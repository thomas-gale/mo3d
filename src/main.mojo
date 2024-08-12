from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota
from tensor import Tensor

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

alias float_type = DType.float32
alias simd_width = 2 * simdwidthof[float_type]()

alias fps = 120
alias width = 256
alias height = 256

fn main() raises:
    # Basic example of using the SDL2 library to create a window and render to it.

    print("Hello, mo3d!")
    print("SIMD width:", simd_width)

    # State
    var t = Tensor[float_type](height, width)

    @parameter
    @no_inline
    fn worker(row: Int):
        @parameter
        @no_inline
        fn compute[simd_width: Int](col: Int):
            """Each time we operate on a `simd_width` vector of pixels."""
            var cx = (col + iota[float_type, simd_width]())
            var cy = row
            var c = ComplexSIMD[float_type, simd_width](cx, cy)
            t.store[simd_width](
                row * width + col, Float32(row/height)
            )

        # Vectorize the call to compute_vector where call gets a chunk of pixels.
        # vectorize[compute, simd_width, unroll_factor=width](width)
        # vectorize[compute, simd_width](width)
        vectorize[compute, 1](width)

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

    fn redraw(sdl: SDL, t: Tensor[float_type]) raises:
        var target_code = sdl.SetRenderTarget(renderer, display)
        if target_code != 0:
            print("Failed to set render target")
            return

        for y in range(height):
            for x in range(width):
                var r = (t[y, x] * 255).cast[DType.uint8]()
                var g = 0
                var b = 0
                _ = sdl.SetRenderDrawColor(renderer, r, g, b, 255)
                _ = sdl.RenderDrawPoint(renderer, y, x)

        _ = sdl.SetRenderTarget(renderer, 0)
        _ = sdl.RenderCopy(renderer, display, 0, 0)
        _ = sdl.RenderPresent(renderer)

    # Test parallelize (number of work items, number of workers)
    parallelize[worker](height, height)


    var event = Event()
    var running: Bool = True
    while True:
        if not running:
            break

        while sdl.PollEvent(Pointer[Event].address_of(event)) != 0:
            if event.type == SDL_QUIT:
                running = False
                break

        redraw(sdl, t)
        _ = sdl.Delay(Int32((1000 / fps)))

    sdl.DestroyWindow(window)
    sdl.Quit()

    print("Goodbye, mo3d!")
