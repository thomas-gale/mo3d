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

from mo3d.math.vec3 import Vec3
from mo3d.math.color3 import Color3
from mo3d.math.ray3 import Ray3
from mo3d.window.sdl2_window import SDL2Window


fn main() raises:
    print("Hello, mo3d!")

    # Settings
    alias fps = 120
    alias width = 800
    # alias width = 400
    alias height = 450
    # alias height = 225
    # var aspect_ratio = width / height
    alias float_type = DType.float32
    # alias S4 = SIMD[float_type, 4]
    alias channels = 4

    # Camera
    var focal_length: Scalar[float_type] = 1.0
    var viewport_height: Scalar[float_type] = 2.0
    var viewport_width: Scalar[float_type] = viewport_height * Scalar[
        float_type
    ](width) / Scalar[float_type](height)
    var camera_center = Vec3[float_type](0.0, 0.0, 0.0)

    # Calculate the vectors across the horizontal and down the vertical viewport edges.
    var viewport_u = Vec3[float_type](viewport_width, 0.0, 0.0)
    var viewport_v = Vec3[float_type](0.0, -1.0 * viewport_height, 0.0)

    print("Viewport U: ", str(viewport_u))
    print("Viewport V: ", str(viewport_v))

    # Calculate the horizontal and vertical delta vectors from pixel to pixel.
    var pixel_delta_u = viewport_u / width
    var pixel_delta_v = viewport_v / height

    # Calculate the location of the upper left pixel.
    var viewport_upper_left = camera_center - Vec3(
        0, 0, focal_length
    ) - viewport_u / 2 - viewport_v / 2

    # var viewport_upper_left = camera_center - Vec3(
    #     SIMD[float_type, 4](0, 0, focal_length)
    # ) - viewport_u / 2 - viewport_v / 2
    var pixel00_loc = viewport_upper_left + 0.5 * (
        pixel_delta_u + pixel_delta_v
    )
    print("Pixel 00 location: ", str(pixel00_loc))

    # Create our own state of the window texture
    var t = Tensor[float_type](height, width, channels)

    # Basic ray coloring
    @parameter
    fn ray_color(r: Ray3[float_type]) -> Color3[float_type]:
        var unit_direction = Vec3.unit(r.dir)
        var a = 0.5 * (unit_direction.y() + 1.0)
        return (1.0 - a) * Color3[float_type](1.0, 1.0, 1.0) + a * Color3[
            float_type
        ](0.5, 0.7, 1.0)

    # Basic compute Kernel
    # Populate the tensor with a colour gradient
    @parameter
    fn compute_row(y: Int):
        @parameter
        fn compute_row_vectorize[simd_width: Int](x: Int):
            # Send a ray into the scene
            var pixel_center = pixel00_loc + (x * pixel_delta_u) + (
                y * pixel_delta_v
            )
            var ray_direction = pixel_center - camera_center
            var r = Ray3(camera_center, ray_direction)

            var pixel_color = ray_color(r)

            t.store[4](
                y * (width * channels) + x * channels,
                SIMD[float_type, 4](
                    1.0,  # A
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

    # Create the window
    var window = SDL2Window.create("mo3d", width, height)

    # Start the main loop
    while not window.should_close():
        start_time = now()
        # parallelize[compute_row](height, height)
        average_compute_time = (1.0 - alpha) * average_compute_time + alpha * (
            now() - start_time
        )
        start_time = now()
        window.redraw(t, channels)
        average_redraw_time = (1.0 - alpha) * average_redraw_time + alpha * (
            now() - start_time
        )
        sleep(1.0 / Float64(fps))


    # WIP: Convince the compiler that we are using these variables
    _ = pixel00_loc
    _ = pixel_delta_u
    _ = pixel_delta_v   
    _ = camera_center
    _ = t

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
