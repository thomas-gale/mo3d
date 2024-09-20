from mo3d.geometry.aabb import AABB

from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import ComponentType
from mo3d.ecs.component_store import ComponentStore


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
    var cumulative_aabb = AABB[T, dim]()
    for entity in entities:
        var entity_position = store.position_components[
            store.entity_to_components[entity[]][ComponentType.Position]
        ]
        var entity_geometry = store.geometry_components[
            store.entity_to_components[entity[]][ComponentType.Geometry]
        ]
        var entity_aabb = entity_geometry.aabb()
        _ = store.add_component(entity[], entity_aabb)
        cumulative_aabb = AABB[T, dim](
            cumulative_aabb, entity_aabb + entity_position
        )

    print("Cumulative AABB: ", str(cumulative_aabb))

    

    # Return the root entity ID of the BVH
    return 0
