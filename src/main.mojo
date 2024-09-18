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
from mo3d.ray.hittable import Hittable
from mo3d.ray.hittable_list import HittableList
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.material.dielectric import Dielectric
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.sphere import Sphere
from mo3d.camera.camera import Camera
from mo3d.window.sdl2_window import SDL2Window

from mo3d.ecs.component_store import ComponentStore


fn main() raises:
    print("-- Hello, mo3d! --")

    # Settings
    alias float_type = DType.float32

    fn random_float(
        min: Scalar[float_type] = 0, max: Scalar[float_type] = 1.0
    ) -> Scalar[float_type]:
        return random_float64(
            min.cast[DType.float64](), max.cast[DType.float64]()
        ).cast[float_type]()

    alias max_fps = 60
    alias fov = 20
    alias aperature = 0.6
    alias width = 800
    alias height = 450
    alias channels = 4
    alias max_depth = 8
    alias max_samples = 1024 * 1024

    # # World
    # var world = HittableList[float_type, 3]()

    # # Ground
    # var mat_ground = Material[float_type, 3](
    #     Lambertian[float_type, 3](Color4[float_type](0.5, 0.5, 0.5))
    # )
    # world.add_hittable(
    #     Hittable[float_type, 3](Sphere(Point[float_type, 3](0, -1000, 0), 1000))
    #     # Hittable[float_type, 3](Sphere(Point[float_type, 3](0, -1000, 0), 1000, mat_ground))
    # )

    # # Random spheres
    # for a in range(-11, 11):
    #     for b in range(-11, 11):
    #         var choose_mat = random_float()
    #         var center = Point[float_type, 3](
    #             a + 0.9 * random_float(), 0.2, b + 0.9 * random_float()
    #         )

    #         if (center - Point[float_type, 3](4, 0.2, 0)).length() > 0.9:
    #             var sphere_material: Material[float_type, 3]

    #             if choose_mat < 0.8:
    #                 # diffuse
    #                 var albedo = Color4[float_type].random() * Color4[
    #                     float_type
    #                 ].random()
    #                 sphere_material = Material[float_type, 3](
    #                     Lambertian[float_type, 3](albedo)
    #                 )
    #                 var center2 = center + Vec[float_type, 3](0, random_float(0, 0.5), 0)
    #                 # world.add_hittable(Hittable[float_type, 3](Sphere(center, center2, 0.2, sphere_material)))
    #                 world.add_hittable(Hittable[float_type, 3](Sphere(center, center2, 0.2)))
    #             elif choose_mat < 0.95:
    #                 # metal
    #                 var albedo = Color4[float_type].random(0.5, 1)
    #                 var fuzz = random_float(0, 0.5)
    #                 sphere_material = Material[float_type, 3](
    #                     Metal[float_type, 3](albedo, fuzz)
    #                 )
    #                 # world.add_hittable(Hittable[float_type, 3](Sphere(center, 0.2, sphere_material)))
    #                 world.add_hittable(Hittable[float_type, 3](Sphere(center, 0.2)))
    #             else:
    #                 # glass
    #                 sphere_material = Material[float_type, 3](
    #                     Dielectric[float_type, 3](1.5)
    #                 )
    #                 # world.add_hittable(Hittable[float_type, 3](Sphere(center, 0.2, sphere_material)))
    #                 world.add_hittable(Hittable[float_type, 3](Sphere(center, 0.2)))

    # # Big spheres
    # var mat1 = Material[float_type, 3](Dielectric[float_type, 3](1.5))
    # # world.add_hittable(Hittable[float_type, 3](Sphere(Point[float_type, 3](0, 1, 0), 1.0, mat1)))
    # world.add_hittable(Hittable[float_type, 3](Sphere(Point[float_type, 3](0, 1, 0), 1.0)))
    # var mat2 = Material[float_type, 3](
    #     Lambertian[float_type, 3](Color4[float_type](0.4, 0.2, 0.1))
    # )
    # # world.add_hittable(Hittable[float_type, 3](Sphere(Point[float_type, 3](-4, 1, 0), 1.0, mat2)))
    # world.add_hittable(Hittable[float_type, 3](Sphere(Point[float_type, 3](-4, 1, 0), 1.0)))
    # var mat3 = Material[float_type, 3](
    #     Metal[float_type, 3](Color4[float_type](0.7, 0.6, 0.5), 0.0)
    # )
    # # world.add_hittable(Hittable[float_type, 3](Sphere(Point[float_type, 3](4, 1, 0), 1.0, mat3)))
    # world.add_hittable(Hittable[float_type, 3](Sphere(Point[float_type, 3](4, 1, 0), 1.0)))

    # ECS
    var store = ComponentStore[float_type, 3]()
    var entity_id = store.create_entity()
    var position = Point[float_type, 3](0, 0, 0)
    _ = store.add_component(entity_id, position)
    var sphere = Sphere[float_type, 3](Point[float_type, 3](0, 0, 0), 1)
    _ = store.add_component(entity_id, Geometry[float_type, 3](sphere))
    var mat = Material[float_type, 3](Lambertian[float_type, 3](Color4[float_type](0.5, 0.5, 0.5)))
    _ = store.add_component(entity_id, mat)

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
    var alpha = 0.1
    var frame_duration = 0.0
    var average_compute_time = 0.0
    var average_redraw_time = 0.0

    # Create window and start the main loop
    var window = SDL2Window.create("mo3d", width, height)

    while window.process_events(camera):
        start_time = now()
        camera.render(store, average_compute_time.cast[DType.int32]() / 10**6, average_redraw_time.cast[DType.int32]() / 10**3)
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
