from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota
from memory import UnsafePointer, bitcast
from pathlib import Path
from sys import simdwidthof
from testing import assert_equal
from time import now, sleep
from utils import StaticIntTuple

from max.tensor import Tensor
from max.extensibility import empty_tensor

from mo3d.math.vec4 import Vec4
from mo3d.math.color4 import Color4
from mo3d.math.ray4 import Ray4
from mo3d.window.sdl2_window import SDL2Window


fn main() raises:
    print("Hello, mo3d!")

    # Settings
    alias fps = 120
    alias width = 800
    alias height = 450
    alias float_type = DType.float32
    alias aspect_ratio = Scalar[
        float_type
    ](width) / Scalar[float_type](height)
    alias S4 = SIMD[float_type, 4]
    alias channels = 4

    # Create our own state of the window texture
    # HACK: It's critical that these are allocated first my Mojo before the @parameter functions later, as we get strange segfaults otherwise...
    var window = SDL2Window.create("mo3d", width, height)
    var t = Tensor[float_type](height, width, channels)

    # Camera
    alias focal_length: Scalar[float_type] = 1.0
    var viewport_height: Scalar[float_type] = 2.0
    var viewport_width: Scalar[float_type] = viewport_height * aspect_ratio
    var camera_center = Vec4(S4(0.0, 0.0, 0.0, 0.0))

    # Calculate the vectors across the horizontal and down the vertical viewport edges.
    var viewport_u = Vec4(S4(viewport_width, 0.0, 0.0, 0.0))
    var viewport_v = Vec4(S4(0.0, -1.0 * viewport_height, 0.0, 0.0))

    # Calculate the horizontal and vertical delta vectors from pixel to pixel.
    var pixel_delta_u = viewport_u / width
    var pixel_delta_v = viewport_v / height

    # Calculate the location of the upper left pixel.
    var viewport_upper_left = camera_center - Vec4(
        S4(0, 0, focal_length, 0.0)
    ) - viewport_u / 2 - viewport_v / 2
    var pixel00_loc = viewport_upper_left + 0.5 * (
        pixel_delta_u + pixel_delta_v
    )

    # Basic ray coloring
    @parameter
    fn ray_color(r: Ray4[float_type]) -> Color4[float_type]:
        var unit_direction = Vec4.unit(r.dir)
        var a = 0.5 * (unit_direction.y() + 1.0)
        return (1.0 - a) * Color4(S4(1.0, 1.0, 1.0, 1.0)) + a * Color4(
            S4(0.5, 0.7, 1.0, 1.0)
        )

    # Basic compute Kernel
    # Populate the tensor with a colour gradient
    @parameter
    fn compute_row(y: Int):
        @parameter
        fn compute_row_vectorize[simd_width: Int](x: Int):
            # Send a ray into the scene from this x, y coordinate
            var pixel_center = pixel00_loc + (x * pixel_delta_u) + (
                y * pixel_delta_v
            )
            var ray_direction = pixel_center - camera_center
            var r = Ray4(camera_center, ray_direction)
            var pixel_color = ray_color(r)

            t.store[4](
                y * (width * channels) + x * channels,
                SIMD[float_type, 4](
                    pixel_color.w(),  # A
                    pixel_color.z(),  # B
                    pixel_color.y(),  # G
                    pixel_color.x(),  # R
                    # 1.0,  # A
                    # 0.0,  # B
                    # (y / (height - 1)).cast[float_type](),  # G
                    # (x / (width - 1)).cast[float_type](),  # R
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
        parallelize[compute_row](
            height, height
        )  # We see a 4x speedup over 1 worker on my machine
        average_compute_time = (1.0 - alpha) * average_compute_time + alpha * (
            now() - start_time
        )
        start_time = now()
        window.redraw(t, channels)
        average_redraw_time = (1.0 - alpha) * average_redraw_time + alpha * (
            now() - start_time
        )
        sleep(1.0 / Float64(fps))

    # WIP: Convince the mojo compiler that we are using these variables while the loop is running...
    _ = pixel00_loc
    _ = pixel_delta_u
    _ = pixel_delta_v
    _ = camera_center

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
