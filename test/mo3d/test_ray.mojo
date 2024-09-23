from math import inf
from testing import assert_equal, assert_true

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord
from mo3d.ray.hit_entity import hit_entity
from mo3d.ecs.component import ComponentType
from mo3d.ecs.component_store import ComponentStore
from mo3d.scene.construct_bvh import construct_bvh
from mo3d.sample.basic_three_sphere_scene import basic_three_sphere_scene_3d
from mo3d.sample.sphere_scene import sphere_scene_3d

alias f32 = DType.float32


fn test_create_empty_ray() raises:
    var r = Ray[f32, 3]()

    var p = Point[f32, 3]()
    var v = Vec[f32, 3]()

    assert_equal(r.orig, p)
    assert_equal(r.dir, v)


fn test_hit_entity() raises:
    var store = ComponentStore[f32, 3]()
    basic_three_sphere_scene_3d(store)
    assert_equal(len(store.entity_to_components), 3)
    var root_entity = construct_bvh(store)
    assert_equal(root_entity, 3)

    var r = Ray[DType.float32, 3](
        Point[f32, 3](0.0, 1.0, 5.0), Vec[f32, 3](0.0, 0.0, -1.0)
    )
    var rec = HitRecord[f32, 3]()
    var ray_t = Interval[f32](-10, 10)
    var hit = hit_entity(store, root_entity, r, ray_t, rec)
    assert_equal(hit, True)


fn test_miss_entity() raises:
    var store = ComponentStore[f32, 3]()
    basic_three_sphere_scene_3d(store)
    assert_equal(len(store.entity_to_components), 3)
    var root_entity = construct_bvh(store)
    assert_equal(root_entity, 3)

    var r = Ray[DType.float32, 3](
        Point[f32, 3](6.0, 1.0, 5.0), Vec[f32, 3](0.0, 0.0, -1.0)
    )
    var rec = HitRecord[f32, 3]()
    var ray_t = Interval[f32](-10, 10)
    var hit = hit_entity(store, root_entity, r, ray_t, rec)
    assert_equal(hit, False)


fn test_hit_entity_complex_scene() raises:
    var store = ComponentStore[f32, 3]()
    sphere_scene_3d(store)
    assert_equal(len(store.entity_to_components), 485)
    var root_entity = construct_bvh(store)
    assert_equal(root_entity, 485)

    # Shoot a ray down from above the scene at the center
    var r = Ray[DType.float32, 3](
        Point[f32, 3](0.0, 100.0, 0.0), Vec[f32, 3](0.0, -1.0, 0.0)
    )
    var rec = HitRecord[f32, 3]()
    var ray_t = Interval[f32](0.001, inf[f32]())
    var hit = hit_entity(store, root_entity, r, ray_t, rec)
    assert_equal(hit, True)
