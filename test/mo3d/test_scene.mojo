from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.ecs.component import ComponentType
from mo3d.ecs.component_store import ComponentStore
from mo3d.scene.construct_bvh import construct_bvh
from mo3d.sample.basic_three_sphere_scene import basic_three_sphere_scene_3d

alias f32 = DType.float32


fn test_construct_bvh() raises:
    var store = ComponentStore[f32, 3]()
    basic_three_sphere_scene_3d(store)
    assert_equal(len(store.entity_to_components), 4)

    var root_entity = construct_bvh(store)
    assert_equal(root_entity, 4)

    assert_true(
        store.entity_has_components(root_entity, ComponentType.BinaryChildren)
    )
    var root_binary_children = store.binary_children_components[
        store.entity_to_components[root_entity][ComponentType.BinaryChildren]
    ]
    assert_equal(root_binary_children.left, 5)
    assert_equal(root_binary_children.right, 6)

    var left_binary_children = store.binary_children_components[
        store.entity_to_components[root_binary_children.left][
            ComponentType.BinaryChildren
        ]
    ]
    assert_equal(left_binary_children.left, 0)
    assert_equal(left_binary_children.right, 1)

    var right_binary_children = store.binary_children_components[
        store.entity_to_components[root_binary_children.right][
            ComponentType.BinaryChildren
        ]
    ]
    assert_equal(right_binary_children.left, 2)
    assert_equal(right_binary_children.right, 3)
