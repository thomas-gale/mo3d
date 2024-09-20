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
    owned entities: List[EntityID],
    start: Int,
    end: Int,
) raises:
    """
    Construct a BVH node from a list of entities.
    """
    print(
        "Building BVH nodes for entity: ",
        entity,
        " checking entities [",
        start,
        ":",
        end,
        ")",
    )

    # Build the bounding box of the span of source objects.
    var bbox = AABB[T, dim]()
    for i in range(start, end):
        var entity = entities[i]
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

    # print("Axis: ", axis, " Span: ", span)

    if span == 1:
        # Leaf node, add a bvh wrapper around the entity
        var entity_binary_children = BinaryChildrenComponent(
            entities[start], entities[start]
        )
        _ = store.add_component(entity, entity_binary_children)
        return
    elif span == 2:
        # Leaf node, add a bvh wrapper around the entities
        var entity_binary_children = BinaryChildrenComponent(
            entities[start], entities[start + 1]
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

        # sort[cmp](Span(entities))
        # sort[cmp](entities[start:end])
        # sort[__lifetime_of(store), cmp](entities)
        # TODO: FIGURE out lifetimes
        # sort[cmp](Span[EntityID, __lifetime_of(store)](entities))
        sort[cmp](entities)

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
    Construct a BVH from all components with position and geometry.
    Returns the root entity ID of the BVH.
    """

    print("Constructing a BVH from all components with position and geometry")

    # Get all entities with position and geometry components
    var entities = store.get_entities_with_components(
        ComponentType.Position | ComponentType.Geometry
    )

    print(
        "Number of entities with position and geometry components: ",
        len(entities),
    )

    # E.g. how Place a bounding box around each entity
    # var cumulative_aabb = AABB[T, dim]()
    # for entity in entities:
    #     var entity_position = store.position_components[
    #         store.entity_to_components[entity[]][ComponentType.Position]
    #     ]
    #     var entity_geometry = store.geometry_components[
    #         store.entity_to_components[entity[]][ComponentType.Geometry]
    #     ]
    #     var entity_aabb = entity_geometry.aabb()
    #     _ = store.add_component(entity[], entity_aabb)
    #     cumulative_aabb = AABB[T, dim](
    #         cumulative_aabb, entity_aabb + entity_position
    #     )

    # print("Cumulative AABB: ", str(cumulative_aabb))

    var root = store.create_entity()
    build_bvh_nodes_recursive[T, dim](root, store, entities, 0, len(entities))

    return root
