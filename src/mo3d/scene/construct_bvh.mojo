from utils import Span

from mo3d.geometry.aabb import AABB
from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import ComponentType, BinaryChildrenComponent
from mo3d.ecs.component_store import ComponentStore


fn build_bvh_nodes_recursive[
    T: DType, dim: Int
](
    entity: EntityID,
    inout store: ComponentStore[T, dim],
    entities: UnsafePointer[List[EntityID]],
    start: Int,
    end: Int,
) raises:
    """
    Construct a BVH node from a list of entities.
    """
    print(
        "Building BVH for entity id: ",
        entity,
        " contains entitie ids [" + str(start) + ":" + str(end) + ")",
    )

    # Build the bounding box of the span of source objects.
    var bbox = AABB[T, dim]()
    for i in range(start, end):
        var entity = entities[][i]
        var entity_position = store.position_components[
            store.entity_to_components[entity][ComponentType.Position]
        ]
        var entity_geometry = store.geometry_components[
            store.entity_to_components[entity][ComponentType.Geometry]
        ]
        var entity_aabb = entity_geometry.aabb()
        bbox = AABB[T, dim](bbox, entity_aabb + entity_position)

    # Update the bounding box of this new BVH node
    _ = store.add_component(entity, bbox)

    var axis = bbox.longest_axis()
    var span = end - start

    if span == 1:
        # Leaf node, add a bvh wrapper around the entity
        var entity_binary_children = BinaryChildrenComponent(
            entities[][start], entities[][start]
        )
        _ = store.add_component(entity, entity_binary_children)
        return
    elif span == 2:
        # Leaf node, add a bvh wrapper around the entities
        var entity_binary_children = BinaryChildrenComponent(
            entities[][start], entities[][start + 1]
        )
        _ = store.add_component(entity, entity_binary_children)
        return
    else:
        # Sort to entities along the longest axis
        @parameter
        fn cmp(entity_a: EntityID, entity_b: EntityID) -> Bool:
            try:
                var entity_a_position = store.position_components[
                    store.entity_to_components[entity_a][ComponentType.Position]
                ]
                var entity_b_position = store.position_components[
                    store.entity_to_components[entity_b][ComponentType.Position]
                ]
                return entity_a_position[axis] < entity_b_position[axis]
            except:
                return False

        # Sort the entities along the longest axis within this span
        var slice = entities[][start:end]
        sort[cmp](slice)

        # Prevent parametric cleanup...
        _ = axis

        var mid = start + span // 2

        # Create left and right child nodes
        var left_child = store.create_entity()
        var right_child = store.create_entity()
        var entity_binary_children = BinaryChildrenComponent(
            left_child, right_child
        )
        _ = store.add_component(entity, entity_binary_children)

        # Recursively build the left and right child nodes
        build_bvh_nodes_recursive[T, dim](
            left_child, store, entities, start, mid
        )
        build_bvh_nodes_recursive[T, dim](
            right_child, store, entities, mid, end
        )


fn construct_bvh[
    T: DType, dim: Int
](inout store: ComponentStore[T, dim]) raises -> EntityID:
    """
    ECS 'system' to construct a BVH from all components in store with position and geometry.
    Returns the root entity ID of the BVH.
    """
    print("Constructing BVH...")
    # Get all entities with position and geometry components
    var entities = store.get_entities_with_components(
        ComponentType.Position | ComponentType.Geometry
    )

    var root = store.create_entity()
    build_bvh_nodes_recursive[T, dim](
        root,
        store,
        UnsafePointer[List[EntityID]].address_of(entities),
        0,
        len(entities),
    )
    _ = entities
    print("Constructed BVH! Root entity id:", root)

    return root
