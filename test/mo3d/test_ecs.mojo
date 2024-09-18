from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.math.point import Point
from mo3d.ecs.component_store import ComponentStore
from mo3d.ecs.component import ComponentID, ComponentTypeID, ComponentType


fn test_create_empty_component_store() raises:
    var store = ComponentStore[DType.float32, 3]()

fn test_add_entity_to_component_store() raises:
    var store = ComponentStore[DType.float32, 3]()
    var entity_id = store.create_entity()
    assert_equal(entity_id, 0)
    assert_true(entity_id in store.entity_to_components)

fn test_add_entity_with_position_to_component_store() raises:
    var store = ComponentStore[DType.float32, 3]()
    var entity_id = store.create_entity()
    assert_equal(entity_id, 0)
    assert_true(entity_id in store.entity_to_components)
    var position = Point[DType.float32, 3](0, 0, 0)
    var position_component_id = store.add_component(entity_id, position)
    assert_equal(position_component_id, store.entity_to_components[entity_id][ComponentType.Position])
    assert_true(store.entity_has_component(entity_id, ComponentType.Position))

    var query = store.entities_with_components(ComponentType.Position)
    assert_equal(len(query), 1)
    assert_equal(query[0], entity_id)
