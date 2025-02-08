from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota, inf
from memory import UnsafePointer, bitcast
from pathlib import Path
from sys import simdwidthof
from testing import assert_equal
from time import sleep, perf_counter

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
from mo3d.scene.construct_bvh import construct_bvh_store
from mo3d.sample.basic_three_sphere_scene import basic_three_sphere_scene_3d
from mo3d.sample.sample_scene import sample_scene_3d
from mo3d.sample.basic_mesh import basic_mesh_scene_3d

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
    alias background_light = Color4[float_type](0.5, 0.7, 1.0, 1.0)
    alias background_dark = Color4[float_type](0.03, 0.06, 0.08, 1.0)

    # ECS
    var store = ComponentStore[float_type, 3]()

    # sphere_scene_3d[float_type](store, 150)
    sample_scene_3d[float_type](store, 4)
    
    # To load the scene from a file
    # var store = ComponentStore[float_type, 3].load("scene.json"

    # To dump the scene
    # store.dump("scene.json")
    
    # sample_scene_3d[float_type](store, 150)
    # sample_scene_3d[float_type](store, 4)
    # basic_mesh_scene_3d[float_type](store)
    var bvh_root = construct_bvh_store(store)

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
        background=background_light
    ]()

    # Collect timing stats - TODO: Tidy and move
    var start_time = perf_counter()
    var frame_duration = 0.0
    var last_compute_time = 0.0
    var last_redraw_time = 0.0

    # Create window and start the main loop
    var window = SDL2Window.create("mo3d", width, height)

    while window.process_events(camera):
        start_time = perf_counter()
        camera.render(
            bvh_root,
            last_compute_time.cast[DType.int64]() * 10**3,
            last_redraw_time.cast[DType.int64]() * 10**6,
        )
        last_compute_time = perf_counter() - start_time
        start_time = perf_counter()
        window.redraw[float_type](camera.get_state(), channels)
        last_redraw_time = perf_counter() - start_time
        frame_duration = (last_compute_time + last_redraw_time) / 10**9
        if frame_duration < 1.0 / Float64(max_fps):
            sleep(1.0 / Float64(max_fps) - frame_duration)

    # DEBUG
    _ = store

    # Print stats
    print(
        "Last compute time: ",
        String(last_compute_time * 10**3),
        " ms",
    )
    print(
        "Last redraw time: ",
        String(last_redraw_time * 10**3),
        " ms",
    )
    print("-- Goodbye, mo3d! --")
