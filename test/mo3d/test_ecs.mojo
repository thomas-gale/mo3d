from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.math.point import Point
from mo3d.ecs.component_store import ComponentStore


fn test_create_empty_component_store() raises:
    var store = ComponentStore[DType.float32, 3]()

fn test_add_entity_to_component_store() raises:
    var store = ComponentStore[DType.float32, 3]()
    var entity_id = 0
    store.add_entity(entity_id)
    assert_true(entity_id in store.entity_component_map)

fn test_add_entity_with_position_to_component_store() raises:
    var store = ComponentStore[DType.float32, 3]()
    var entity_id = 0
    store.add_entity(entity_id)
    assert_true(entity_id in store.entity_component_map)
    var position = Point[DType.float32, 3](0, 0, 0)
    var position_component_id = store.add_component(entity_id, position)
    assert_true(position_component_id in store.entity_component_map[entity_id])
