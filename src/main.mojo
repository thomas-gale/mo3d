from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota, inf
from memory import UnsafePointer, bitcast
from pathlib import Path
from random import random_float64
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

from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.material.dielectric import Dielectric
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.sphere import Sphere
from mo3d.camera.camera import Camera
from mo3d.window.sdl2_window import SDL2Window

from mo3d.ecs.component_store import ComponentStore
from mo3d.scene.construct_bvh import construct_bvh
from mo3d.sample.basic_three_sphere_scene import basic_three_sphere_scene_3d
from mo3d.sample.sphere_scene import sphere_scene_3d


fn main() raises:
    print("-- Hello, mo3d! --")

    # Settings
    alias float_type = DType.float32

    alias max_fps = 60
    alias fov = 20
    alias aperature = 0.6
    alias width = 800
    alias height = 450
    alias channels = 4
    alias max_depth = 8
    alias max_samples = 1024 * 1024

    # ECS
    var store = ComponentStore[float_type, 3]()
    # basic_three_sphere_scene_3d[float_type](store)
    sphere_scene_3d[float_type](store)
    var bvh_root_entity = construct_bvh(store)

    # Camera
    var camera = Camera[
        T=float_type,
        fov=fov,
        aperature=aperature,
        width=width,
        height=height,
        channels=channels,
        max_depth=max_depth,
        max_samples=max_samples,
    ]()

    # Collect timing stats - TODO: Tidy and move
    var start_time = now()
    var frame_duration = 0.0
    var last_compute_time = 0.0
    var last_redraw_time = 0.0

    # Create window and start the main loop
    var window = SDL2Window.create("mo3d", width, height)

    while window.process_events(camera):
        start_time = now()
        camera.render(
            store,
            bvh_root_entity,
            last_compute_time.cast[DType.int64]() / 10**6,
            last_redraw_time.cast[DType.int64]() / 10**3,
        )
        last_compute_time = now() - start_time
        start_time = now()
        window.redraw[float_type](camera.get_state(), channels)
        last_redraw_time = now() - start_time
        frame_duration = (last_compute_time + last_redraw_time) / 10**9
        if frame_duration < 1.0 / Float64(max_fps):
            sleep(1.0 / Float64(max_fps) - frame_duration)

    # DEBUG
    _ = store

    # Print stats
    print(
        "Last compute time: ",
        str(last_compute_time / (1000 * 1000)),
        " ms",
    )
    print(
        "Last redraw time: ",
        str(last_redraw_time / (1000 * 1000)),
        " ms",
    )
    print("-- Goodbye, mo3d! --")
