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


fn basic_three_sphere_scene_3d[
    T: DType
](inout store: ComponentStore[T, 3]) raises:
    """
    The classic end scene from the Ray Tracing in One Weekend by Peter Shirley.
    """
    alias dim = 3

    var mat1 = Material[T, dim](Dielectric[T, dim](1.5))
    var sphere1 = Sphere[T, dim](1.0)
    var sphere1_entity_id = store.create_entity()
    _ = store.add_components(
        sphere1_entity_id,
        Point[T, dim](0, 1, 0),
        Geometry[T, dim](sphere1),
        mat1,
    )

    var mat2 = Material[T, dim](Lambertian[T, dim](Color4[T](0.4, 0.2, 0.1)))
    var sphere2 = Sphere[T, dim](1.0)
    var sphere2_entity_id = store.create_entity()
    _ = store.add_components(
        sphere2_entity_id,
        Point[T, dim](-4, 1, 0),
        Geometry[T, dim](sphere2),
        mat2,
    )

    var mat3 = Material[T, dim](Metal[T, dim](Color4[T](0.7, 0.6, 0.5), 0.0))
    var sphere3 = Sphere[T, dim](1.0)
    var sphere3_entity_id = store.create_entity()
    _ = store.add_components(
        sphere3_entity_id,
        Point[T, dim](4, 1, 0),
        Geometry[T, dim](sphere3),
        mat3,
    )
