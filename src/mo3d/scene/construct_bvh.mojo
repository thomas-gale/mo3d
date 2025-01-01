from memory.arc import ArcPointer
from utils import Variant
from collections import InlineArray

from mo3d.geometry.aabb import AABB
from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import ComponentType
from mo3d.ecs.component_store import ComponentStore

from mo3d.geometry.geometry import Geometry
from mo3d.material.material import Material

from mo3d.math.point import Point

@value 
struct Hittable[T : DType, dim : Int]:
    var geometry : Geometry[T, dim]
    var material : Material[T, dim]
    var position : Point[T, dim]

@value
struct BVHSplit[T: DType, dim: Int]:
    var left : ArcPointer[BVHNode[T, dim]]
    var right : ArcPointer[BVHNode[T, dim]]

@value
struct BVHNode[T: DType, dim: Int]:
    alias Variant = Variant[
        BVHSplit[T, dim], 
        Hittable[T, dim]]
    var _wrapped: Self.Variant
    var box : AABB[T, dim]

    fn count_hittables(self) -> Int:
        if self._wrapped.isa[BVHSplit[T, dim]]():
            return self._wrapped[BVHSplit[T, dim]].left[].count_hittables() +  self._wrapped[BVHSplit[T, dim]].right[].count_hittables()
        else:
            return 1

    fn count_nodes(self) -> Int:
        if self._wrapped.isa[BVHSplit[T, dim]]():
            return 1 + self._wrapped[BVHSplit[T, dim]].left[].count_hittables() +  self._wrapped[BVHSplit[T, dim]].right[].count_hittables()
        else:
            return 0



fn build_bvh_nodes_recursive[
    T: DType, dim: Int
](
    store: ComponentStore[T, dim],
    mut entities: List[EntityID],
    start: Int,
    end: Int,
) raises -> BVHNode[T, dim]:
    """
    Construct a BVH node from a list of entities.
    """
    # print(
    #     "Building BVH for entity id: ",
    #     entity,
    #     " contains entitiy ids [" + str(start) + ":" + str(end) + ")",
    # )

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

    var axis = bbox.longest_axis()
    var span = end - start

    # print(
    #     "Bounding box for entity id: ",
    #     entity,
    #     " is: ",
    #     str(bbox),
    #     " with longest axis: ",
    #     axis,
    #     " and span: ",
    #     span,
    # )

    if span == 1:
        # Leaf node, add a bvh wrapper around the entity
        var entity_geometry = store.geometry_components[
            store.entity_to_components[start][ComponentType.Geometry]
        ]
        var entity_material = store.material_components[
            store.entity_to_components[start][ComponentType.Material]
        ]
        var entity_position = store.position_components[
            store.entity_to_components[start][ComponentType.Position]
        ]
        return BVHNode[T, dim](
            Hittable(entity_geometry, entity_material, entity_position), 
            bbox)
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
        var slice = entities[start:end]
        sort[cmp](slice)

        # Prevent parametric cleanup...
        _ = axis

        var mid = start + span // 2

        # Recursively build the left and right child nodes
        var left_child = build_bvh_nodes_recursive[T, dim](
            store, entities, start, mid
        )
        var right_child = build_bvh_nodes_recursive[T, dim](
            store, entities, mid, end
        )
        return BVHNode[T, dim](
            BVHSplit[T, dim](left_child, right_child),
            bbox
        )


fn construct_bvh[
    T: DType, dim: Int
](store: ComponentStore[T, dim]) raises -> BVHNode[T, dim]:
    """
    ECS 'system' to construct a BVH from all components in store with position and geometry.
    Returns the root entity ID of the BVH.
    """
    print("Constructing BVH...")
    # Get all entities with position and geometry components
    var entities = store.get_entities_with_components(
        ComponentType.Position | ComponentType.Geometry
    )

    var root = build_bvh_nodes_recursive[T, dim](
        store,
        entities,
        0,
        len(entities),
    )
    print("Constructed BVH!")
    return root
