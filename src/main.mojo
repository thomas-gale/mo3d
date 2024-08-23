from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota
from memory import UnsafePointer, bitcast
from sys import simdwidthof
from testing import assert_equal
from time import now, sleep
from utils import StaticIntTuple

from max.tensor import Tensor
from max.extensibility import empty_tensor

from mo3d.math.vec4 import Vec4
from mo3d.window.sdl2_window import SDL2Window


fn main() raises:
    print("Hello, mo3d!")

    # Settings
    alias fps = 120
    alias width = 800
    alias height = 450
    alias aspect_ratio = width / height
    alias channels = Vec4[DType.float32].size
    alias float_type = DType.float32

    # Camera
    alias focal_length = 1.0
    alias viewport_height = 2.0
    alias viewport_width = viewport_height * aspect_ratio
    alias camera_center = Vec4(SIMD[float_type, 4](0.0, 0.0, 0.0, 0.0))

    # Calculate the vectors across the horizontal and down the vertical viewport edges.
    alias viewport_u = Vec4(
        SIMD[float_type, 4](viewport_width.cast[float_type](), 0.0, 0.0, 0.0)
    )
    alias viewport_v = Vec4(
        SIMD[float_type, 4](0.0, -viewport_height, 0.0, 0.0)
    )

    # Calculate the horizontal and vertical delta vectors from pixel to pixel.
    alias pixel_delta_u = viewport_u / width
    alias pixel_delta_v = viewport_v / height

    # Calculate the location of the upper left pixel.
    var viewport_upper_left = camera_center - Vec4(
        SIMD[float_type, 4](0, 0, focal_length)
    ) - viewport_u / 2 - viewport_v / 2
    var pixel00_loc = viewport_upper_left + (
        pixel_delta_u + pixel_delta_v
    ) * 0.5
    print("Pixel 00 location: ", str(pixel00_loc))

    # Create the window 
    var window = SDL2Window.create("mo3d", width, height)

    # Create our own state of the window texture
    var t = Tensor[float_type](height, width, channels)

    # Basic compute Kernel 
    # Populate the tensor with a colour gradient
    @parameter
    fn compute_row(y: Int):
        @parameter
        fn compute_row_vectorize[simd_width: Int](x: Int):
            # Send a ray into the scene

            t.store[4](
                y * (width * channels) + x * channels,
                SIMD[float_type, 4](
                    1.0,  # A
                    0.0,  # B
                    (y / (height - 1)).cast[float_type](),  # G
                    (x / (width - 1)).cast[float_type](),  # R
                ),
            )

        vectorize[compute_row_vectorize, 1](width)

    # Inital values
    parallelize[compute_row](height, height)

    # Collect timing stats
    var start_time = now()
    var alpha = 0.1
    var average_compute_time = 0.0
    var average_redraw_time = 0.0

    # Start the main loop
    while not window.should_close():
        start_time = now()
        parallelize[compute_row](height, height)
        average_compute_time = (1.0 - alpha) * average_compute_time + alpha * (
            now() - start_time
        )
        start_time = now()
        window.redraw(t, channels)
        average_redraw_time = (1.0 - alpha) * average_redraw_time + alpha * (
            now() - start_time
        )
        sleep(1.0 / Float64(fps))

    

    # Print stats
    print(
        "Average compute time: ",
        str(average_compute_time / (1000 * 1000)),
        " ms",
    )
    print(
        "Average redraw time: ",
        str(average_redraw_time / (1000 * 1000)),
        " ms",
    )
    print("Goodbye, mo3d!")
