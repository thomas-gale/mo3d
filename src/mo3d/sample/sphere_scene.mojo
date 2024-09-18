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
    """
    The classic end scene from the Ray Tracing in One Weekend by Peter Shirley.
    """
    alias dim = 3

    fn random_float(min: Scalar[T] = 0, max: Scalar[T] = 1.0) -> Scalar[T]:
        return random_float64(
            min.cast[DType.float64](), max.cast[DType.float64]()
        ).cast[T]()

    # Ground
    var mat_ground = Material[T, dim](
        Lambertian[T, dim](Color4[T](0.5, 0.5, 0.5))
    )
    print(str(Color4[T](0.5, 0.5, 0.5)))
    var ground = Sphere[T, dim](1000)
    var ground_entity_id = store.create_entity()
    _ = store.add_components(
        ground_entity_id,
        Point[T, dim](0, -1000, 0),
        Geometry[T, dim](ground),
        mat_ground,
    )

    # Random spheres
    for a in range(-11, 11):
        for b in range(-11, 11):
            var choose_mat = random_float()
            var center = Point[T, dim](
                a + 0.9 * random_float(), 0.2, b + 0.9 * random_float()
            )

            if (center - Point[T, dim](4, 0.2, 0)).length() > 0.9:
                var sphere_material: Material[T, dim]

                if choose_mat < 0.8:
                    # diffuse
                    var albedo = Color4[T].random() * Color4[T].random()
                    sphere_material = Material[T, dim](
                        Lambertian[T, dim](albedo)
                    )
                    var sphere = Sphere[T, dim](0.2)
                    var sphere_entity_id = store.create_entity()
                    _ = store.add_components(
                        sphere_entity_id,
                        center,
                        Geometry[T, dim](sphere),
                        sphere_material,
                    )
                elif choose_mat < 0.95:
                    # metal
                    var albedo = Color4[T].random(0.5, 1)
                    var fuzz = random_float(0, 0.5)
                    sphere_material = Material[T, dim](
                        Metal[T, dim](albedo, fuzz)
                    )
                    var sphere = Sphere[T, dim](0.2)
                    var sphere_entity_id = store.create_entity()
                    _ = store.add_components(
                        sphere_entity_id,
                        center,
                        Geometry[T, dim](sphere),
                        sphere_material,
                    )
                else:
                    # glass
                    sphere_material = Material[T, dim](Dielectric[T, dim](1.5))
                    var sphere = Sphere[T, dim](0.2)
                    var sphere_entity_id = store.create_entity()
                    _ = store.add_components(
                        sphere_entity_id,
                        center,
                        Geometry[T, dim](sphere),
                        sphere_material,
                    )

    # Big Spheres
    var mat1 = Material[T, dim](Dielectric[T, dim](1.5))
    var sphere1 = Sphere[T, dim](1.0)
    var sphere1_entity_id = store.create_entity()
    _ = store.add_components(sphere1_entity_id, Point[T, dim](0, 1, 0), Geometry[T, dim](sphere1), mat1)

    var mat2 = Material[T, dim](Lambertian[T, dim](Color4[T](0.4, 0.2, 0.1)))
    var sphere2 = Sphere[T, dim](1.0)
    var sphere2_entity_id = store.create_entity()
    _ = store.add_components(sphere2_entity_id, Point[T, dim](-4, 1, 0), Geometry[T, dim](sphere2), mat2)

    var mat3 = Material[T, dim](Metal[T, dim](Color4[T](0.7, 0.6, 0.5), 0.0))
    var sphere3 = Sphere[T, dim](1.0)
    var sphere3_entity_id = store.create_entity()
    _ = store.add_components(sphere3_entity_id, Point[T, dim](4, 1, 0), Geometry[T, dim](sphere3), mat3)
