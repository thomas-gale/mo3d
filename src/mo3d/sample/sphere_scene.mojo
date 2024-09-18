from random import random_float64

from mo3d.ecs.component_store import ComponentStore
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.color4 import Color4
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.sphere import Sphere
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.material.dielectric import Dielectric


fn sphere_scene_3d[T: DType](inout store: ComponentStore[T, 3]) raises:
    alias dim = 3
    fn random_float(min: Scalar[T] = 0, max: Scalar[T] = 1.0) -> Scalar[T]:
        return random_float64(
            min.cast[DType.float64](), max.cast[DType.float64]()
        ).cast[T]()

    # Ground
    var mat_ground = Material[T, dim](Lambertian[T, dim](Color4[T](0.5, 0.5, 0.5)))
    var ground = Sphere[T, dim](1000)
    var ground_entity_id = store.create_entity()
    _ = store.add_component(ground_entity_id, Point[T, dim](0, -1000, 0))
    _ = store.add_component(ground_entity_id, Geometry[T, dim](ground))
    _ = store.add_component(ground_entity_id, mat_ground)

    # Random spheres
    # for a in range(-11, 11):
    #     for b in range(-11, 11):
    #         var choose_mat = random_float()
    #         var center = Point[T, dim](
    #             a + 0.9 * random_float(), 0.2, b + 0.9 * random_float()
    #         )

    #         if (center - Point[T, dim](4, 0.2, 0)).length() > 0.9:
    #             var sphere_material: Material[T, dim]

    #             if choose_mat < 0.8:
    #                 # diffuse
    #                 var albedo = Color4[T].random() * Color4[T].random()
    #                 sphere_material = Material[T, dim](
    #                     Lambertian[T, dim](albedo)
    #                 )
    #                 var center2 = center + Vec[T, dim](0, random_float(0, 0.5), 0)
    #                 var sphere = Sphere[T, dim](center, center2, 0.2)
    #                 var sphere_entity_id = store.create_entity()
    #                 _ = store.add_component(sphere_entity_id, center)
    #                 _ = store.add_component(sphere_entity_id, Geometry[T, dim](sphere))
    #                 _ = store.add_component(sphere_entity_id, sphere_material)
    #             elif choose_mat < 0.95:
    #                 # metal
    #                 var albedo = Color4[T].random(0.5, 1)
    #                 var fuzz = random_float(0, 0.5)
    #                 sphere_material = Material[T, dim](
    #                     Metal[T, dim](albedo, fuzz)
    #                 )
    #                 var sphere = Sphere[T, dim](center, 0.2)
    #                 var sphere_entity_id = store.create_entity()
    #                 _ = store.add_component(sphere_entity_id, center)
    #                 _ = store.add_component(sphere_entity_id, Geometry[T, dim](sphere))
    #                 _ = store.add_component(sphere_entity_id, sphere_material)
    #             else:
    #                 # glass
    #                 sphere_material = Material[T, dim](
    #                     Dielectric[T, dim](1.5)
    #                 )
    #                 var sphere = Sphere[T, dim](center, 0.2)
    #                 var sphere_entity_id = store.create_entity()
    #                 _ = store.add_component(sphere_entity_id, center)
    #                 _ = store.add_component(sphere_entity_id, Geometry[T, dim](sphere))
    #                 _ = store.add_component(sphere_entity_id, sphere_material)

    # Big Sphere
    var mat1 = Material[T, dim](Dielectric[T, dim](1.5))
    var sphere1 = Sphere[T, dim](1.0)
    var sphere1_entity_id = store.create_entity()
    _ = store.add_component(sphere1_entity_id, Point[T, dim](0, 1, 0))
    _ = store.add_component(sphere1_entity_id, Geometry[T, dim](sphere1))
    _ = store.add_component(sphere1_entity_id, mat1)

    var mat2 = Material[T, dim](Lambertian[T, dim](Color4[T](0.4, 0.2, 0.1)))
    var sphere2 = Sphere[T, dim](1.0)
    var sphere2_entity_id = store.create_entity()
    _ = store.add_component(sphere2_entity_id, Point[T, dim](-4, 1, 0))
    _ = store.add_component(sphere2_entity_id, Geometry[T, dim](sphere2))
    _ = store.add_component(sphere2_entity_id, mat2)

    var mat3 = Material[T, dim](Metal[T, dim](Color4[T](0.7, 0.6, 0.5), 0.0))
    var sphere3 = Sphere[T, dim](1.0)
    var sphere3_entity_id = store.create_entity()
    _ = store.add_component(sphere3_entity_id, Point[T, dim](4, 1, 0))
    _ = store.add_component(sphere3_entity_id, Geometry[T, dim](sphere3))
    _ = store.add_component(sphere3_entity_id, mat3)

    # Random spheres
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
