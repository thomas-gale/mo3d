from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.math.point import Point
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.sphere import Sphere

from mo3d.ecs.component_store import ComponentStore
from mo3d.ecs.component import ComponentID, ComponentTypeID, ComponentType, BinaryChildrenComponent

alias f32 = DType.float32


fn test_create_empty_component_store() raises:
    var store = ComponentStore[f32, 3]()


fn test_add_entity_to_component_store() raises:
    var store = ComponentStore[f32, 3]()
    var entity_id = store.create_entity()
    assert_equal(entity_id, 0)
    assert_true(entity_id in store.entity_to_components)


fn test_add_entity_with_position_to_component_store() raises:
    var store = ComponentStore[f32, 3]()
    var entity_id = store.create_entity()
    assert_equal(entity_id, 0)
    assert_true(entity_id in store.entity_to_components)
    var position = Point[f32, 3](0, 0, 0)
    var position_component_id = store.add_component(entity_id, position)
    assert_equal(
        position_component_id,
        store.entity_to_components[entity_id][ComponentType.Position],
    )
    assert_true(store.entity_has_components(entity_id, ComponentType.Position))

    var query = store.get_entities_with_components(ComponentType.Position)
    assert_equal(len(query), 1)
    assert_equal(query[0], entity_id)


fn test_add_sphere_entity_to_component_store() raises:
    var store = ComponentStore[f32, 3]()
    var entity_id = store.create_entity()
    var position = Point[f32, 3](1, 2, 3)
    _ = store.add_component(entity_id, position)
    var sphere = Sphere[f32, 3](1)
    _ = store.add_component(entity_id, Geometry[f32, 3](sphere))

    var query1 = store.get_entities_with_components(ComponentType.Position)
    assert_equal(len(query1), 1)
    assert_equal(query1[0], entity_id)

    var query2 = store.get_entities_with_components(
        ComponentType.Position | ComponentType.Geometry
    )
    assert_equal(len(query2), 1)

    var query3 = store.get_entities_with_components(
        ComponentType.Position | ComponentType.Geometry | ComponentType.Velocity
    )
    assert_equal(len(query3), 0)


fn test_add_bvh_entity_to_component_store() raises:
    var store = ComponentStore[f32, 3]()
    var entity_id = store.create_entity()
    var position = Point[f32, 3](1, 2, 3)
    _ = store.add_component(entity_id, position)
    var sphere = Sphere[f32, 3](1)
    _ = store.add_component(entity_id, Geometry[f32, 3](sphere))
    _ = store.add_component(entity_id, sphere.aabb())

    var query = store.get_entities_with_components(ComponentType.BoundingBox)
    assert_equal(len(query), 1)
    var bvh = store.bounding_box_components[
        store.entity_to_components[query[0]][ComponentType.BoundingBox]
    ]
    print(str(bvh))

    assert_almost_equal(bvh._bounds[0].min, -1.0)
    assert_almost_equal(bvh._bounds[0].max, 1.0)
    assert_almost_equal(bvh._bounds[1].min, -1.0)
    assert_almost_equal(bvh._bounds[1].max, 1.0)
    assert_almost_equal(bvh._bounds[2].min, -1.0)
    assert_almost_equal(bvh._bounds[2].max, 1.0)

fn test_add_entity_with_children_to_component_store() raises:
    var store = ComponentStore[f32, 3]()
    var parent_entity = store.create_entity()
    var child1_entity = store.create_entity()
    var child2_entity = store.create_entity()

    var binary_children_component = BinaryChildrenComponent(child1_entity, child2_entity)
    _ = store.add_component(parent_entity, binary_children_component)

    var query = store.get_entities_with_components(ComponentType.BinaryChildren)
    assert_equal(len(query), 1)
    assert_equal(query[0], parent_entity)
