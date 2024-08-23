from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota

from memory import UnsafePointer, bitcast
from sys import simdwidthof
from tensor import Tensor
from testing import assert_equal
from time import now, sleep

from mo3d.window.sdl2_window import SDL2Window

# from mo3d.window.sdl2 import (
#     SDL_INIT_VIDEO,
#     SDL_PIXELFORMAT_RGBA8888,
#     SDL_QUIT,
#     SDL_TEXTUREACCESS_STREAMING,
#     SDL_WINDOWPOS_CENTERED,
#     SDL_WINDOW_SHOWN,
#     SDL,
#     SDL_Rect,
#     SDL_Window,
#     SDL_Texture,
#     Event,
# )
from mo3d.math.vec4 import Vec4

alias fps = 120
alias width = 512
alias height = 512
alias channels = Vec4[DType.float32].size

alias float_type = DType.float32


fn main() raises:
    print("Hello, mo3d!")

    # Create our own state of the window
    var t = Tensor[float_type](width, height, channels)

    # Populate the tensor with a colour gradient
    for y in range(height):
        for x in range(width):
            t.store[4](
                y * (width * channels) + x * channels,
                SIMD[float_type, 4](
                    1.0,  # A
                    0.0,  # B
                    (y / (height - 1)).cast[float_type](),  # G
                    (x / (width - 1)).cast[float_type](),  # R
                ),
            )

    # Collect timing stats
    var start_time = now()
    var alpha = 0.1
    var average_redraw_time = 0.0

    # Create the window and start the main loop
    var window = SDL2Window.create("mo3d", width, height)
    while not window.should_close():
        start_time = now()
        window.redraw(t, channels)
        average_redraw_time = (1.0 - alpha) * average_redraw_time + alpha * (
            now() - start_time
        )
        sleep(1.0 / Float64(fps))

    # Print stats
    print(
        "Average redraw time: ",
        str(average_redraw_time / (1000 * 1000)),
        " ms",
    )
    print("Goodbye, mo3d!")
