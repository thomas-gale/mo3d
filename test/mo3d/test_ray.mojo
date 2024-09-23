from testing import assert_equal

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
    var hit = hit_entity(store, root_entity, r, Interval[f32](-10, 10), rec)
    assert_equal(hit, True)


fn test_miss_entity() raises:
    var store = ComponentStore[f32, 3]()
    basic_three_sphere_scene_3d(store)
    assert_equal(len(store.entity_to_components), 3)
    var root_entity = construct_bvh(store)
    assert_equal(root_entity, 3)

    var r = Ray[DType.float32, 3](
        Point[f32, 3](5.0, 0.0, 5.0), Vec[f32, 3](0.0, 0.0, -1.0)
    )
    var rec = HitRecord[f32, 3]()
    var hit = hit_entity(store, root_entity, r, Interval[f32](-10, 10), rec)
    assert_equal(hit, False)
