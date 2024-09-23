from utils import Span

from mo3d.math.interval import Interval
from mo3d.geometry.aabb import AABB
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import ComponentType, BinaryChildrenComponent
from mo3d.ecs.component_store import ComponentStore


fn hit_entity[
    T: DType, dim: Int
](
    store: ComponentStore[T, dim],
    entity: EntityID,
    r: Ray[T, dim],
    owned ray_t: Interval[T],
    inout rec: HitRecord[T, dim],
) -> Bool:
    """
    ECS 'system' to intersect a ray with an entity in the component store.
    """
    # Is the entity a BVH or Leaf Geometry?
    if store.entity_has_components(
        entity, ComponentType.BoundingBox | ComponentType.BinaryChildren
    ):
        return hit_bvh(store, entity, r, ray_t, rec)
    elif store.entity_has_components(
        entity,
        ComponentType.Position
        | ComponentType.Geometry
        | ComponentType.Material,
    ):
        return hit_geometry(store, entity, r, ray_t, rec)
    else:
        print("Entity is unhitable", entity)
        return False


fn hit_bvh[
    T: DType, dim: Int
](
    store: ComponentStore[T, dim],
    bvh_entity: EntityID,
    r: Ray[T, dim],
    owned ray_t: Interval[T],
    inout rec: HitRecord[T, dim],
) -> Bool:
    """
    ECS 'system' to intersect a ray with a bvh entity in the component store.
    """
    try:
        var bbox_comp_id = store.entity_to_components[bvh_entity][
            ComponentType.BoundingBox
        ]
        var bbox = store.bounding_box_components[bbox_comp_id]

        if not bbox.hit(r, ray_t):
            return False

        var binary_children_comp_id = store.entity_to_components[bvh_entity][
            ComponentType.BinaryChildren
        ]
        var binary_children = store.binary_children_components[
            binary_children_comp_id
        ]

        var hit_left = hit_entity(store, binary_children.left, r, ray_t, rec)
        var hit_right = hit_entity(
            store,
            binary_children.right,
            r,
            Interval(ray_t.min, rec.t if hit_left else ray_t.max), # If hit on left, limit right ray_t max to hit point on left
            rec,
        )
        return hit_left or hit_right
    except:
        print("Error in hit_bvh")
        return False


fn hit_geometry[
    T: DType, dim: Int
](
    store: ComponentStore[T, dim],
    geometry_entity: EntityID,
    r: Ray[T, dim],
    owned ray_t: Interval[T],
    inout rec: HitRecord[T, dim],
) -> Bool:
    """
    ECS 'system' to intersect a ray with a geometric entity in the component store.
    The component must have geometry, position and material components.
    """
    try:
        var position_comp_id = store.entity_to_components[geometry_entity][
            ComponentType.Position
        ]
        var position = store.position_components[position_comp_id]
        var geometry_comp_id = store.entity_to_components[geometry_entity][
            ComponentType.Geometry
        ]
        var geometry = store.geometry_components[geometry_comp_id]
        var material_comp_id = store.entity_to_components[geometry_entity][
            ComponentType.Material
        ]
        var material = store.material_components[material_comp_id]

        return geometry.hit(r, ray_t, rec, position, material)
    except:
        print("Error in hit_geometry")
        return False
