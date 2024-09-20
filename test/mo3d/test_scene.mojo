from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.ecs.component_store import ComponentStore
from mo3d.scene.construct_bvh import construct_bvh
from mo3d.sample.basic_three_sphere_scene import basic_three_sphere_scene_3d

alias f32 = DType.float32


fn test_construct_bvh() raises:
    var store = ComponentStore[f32, 3]()
    basic_three_sphere_scene_3d(store)

    var root_entity = construct_bvh(store)

    # Fail while we build
    assert_true(False)
