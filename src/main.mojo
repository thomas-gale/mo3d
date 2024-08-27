from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota, inf
from memory import UnsafePointer, bitcast
from pathlib import Path
from sys import simdwidthof
from testing import assert_equal
from time import now, sleep
from utils import StaticIntTuple

from max.tensor import Tensor

from mo3d.precision import float_type
from mo3d.math.interval import Interval
from mo3d.math.vec4 import Vec4
from mo3d.math.point4 import Point4
from mo3d.ray.ray4 import Ray4
from mo3d.ray.hittable import Hittable, HitRecord
from mo3d.ray.hittable_list import HittableList
from mo3d.ray.sphere import Sphere
from mo3d.camera.camera import Camera
from mo3d.window.sdl2_window import SDL2Window


fn main() raises:
    print("-- Hello, mo3d! --")

    # Settings
    alias max_fps = 60
    alias width = 800
    alias height = 450
    alias aspect_ratio = Scalar[float_type](width) / Scalar[float_type](height)
    alias S4 = SIMD[float_type, 4]
    alias channels = 4
    alias max_depth = 8

    # World
    var world = HittableList()
    world.add_sphere(Sphere(Point4(S4(0, 0, -1, 0)), 0.5))
    world.add_sphere(Sphere(Point4(S4(0, -100.5, -1, 0)), 100))

    # Camera
    var camera = Camera[width, height, channels, max_depth]()

    # Collect timing stats - TODO: Tidy and move
    var start_time = now()
    var alpha = 0.1
    var frame_duration = 0.0
    var average_compute_time = 0.0
    var average_redraw_time = 0.0

    # Create window and start the main loop
    var window = SDL2Window.create("mo3d", width, height)
    while not window.should_close():
        start_time = now()
        camera.render(world)
        average_compute_time = (1.0 - alpha) * average_compute_time + alpha * (
            now() - start_time
        )
        frame_duration = now() - start_time
        start_time = now()
        window.redraw[float_type](camera.get_state(), channels)
        average_redraw_time = (1.0 - alpha) * average_redraw_time + alpha * (
            now() - start_time
        )
        frame_duration += now() - start_time
        frame_duration = frame_duration / 10**9
        if frame_duration < 1.0 / Float64(max_fps):
            sleep(1.0 / Float64(max_fps) - frame_duration)

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
