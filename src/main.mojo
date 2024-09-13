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

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.mat import Mat
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.color4 import Color4
from mo3d.ray.hit_record import HitRecord
from mo3d.ray.hittable_list import HittableList
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.material.dielectric import Dielectric
from mo3d.geometry.sphere import Sphere
from mo3d.camera.camera import Camera
from mo3d.window.sdl2_window import SDL2Window


fn main() raises:
    print("-- Hello, mo3d! --")

    # Settings
    alias float_type = DType.float32

    alias max_fps = 60
    alias width = 800
    alias height = 450
    alias channels = 4
    alias max_depth = 8
    alias max_samples = 1024 * 1024

    # World
    var world = HittableList[float_type, 3]()

    var mat_ground = Material[float_type, 3](
        Lambertian[float_type, 3](Color4[float_type](0.8, 0.8, 0.0))
    )
    var mat_center = Material[float_type, 3](
        Lambertian[float_type, 3](Color4[float_type](0.1, 0.2, 0.5))
    )
    var mat_left = Material[float_type, 3](Dielectric[float_type, 3](1.50))
    var mat_bubble = Material[float_type, 3](Dielectric[float_type, 3](1.00/1.50))
    var mat_right = Material[float_type, 3](
        Metal[float_type, 3](Color4[float_type](0.8, 0.6, 0.2), 1.0)
    )

    world.add_sphere(Sphere(Point[float_type, 3](0, 0, 0), 0.5, mat_center))
    world.add_sphere(Sphere(Point[float_type, 3](1, 0, 0), 0.5, mat_right))
    world.add_sphere(Sphere(Point[float_type, 3](-1, 0, 0), 0.5, mat_left))
    world.add_sphere(Sphere(Point[float_type, 3](-1, 0, 0), 0.4, mat_bubble))
    world.add_sphere(
        Sphere(Point[float_type, 3](0, -100.5, 0), 100, mat_ground)
    )

    # Camera
    var camera = Camera[
        float_type, width, height, channels, max_depth, max_samples
    ]()

    # Collect timing stats - TODO: Tidy and move
    var start_time = now()
    var alpha = 0.1
    var frame_duration = 0.0
    var average_compute_time = 0.0
    var average_redraw_time = 0.0

    # Create window and start the main loop
    var window = SDL2Window.create("mo3d", width, height)

    while window.process_events(camera):
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
    print("-- Goodbye, mo3d! --")
