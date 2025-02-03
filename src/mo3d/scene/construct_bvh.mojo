from memory.arc import ArcPointer
from utils import Variant
from collections import InlineArray, Dict
from math.math import iota

from mo3d.geometry.aabb import AABB
from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import ComponentType
from mo3d.ecs.component_store import ComponentStore

from mo3d.geometry.geometry import Geometry, Hittable
from mo3d.material.material import Material

from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.math.point import Point
from mo3d.math.interval import Interval

@value 
struct HittableEntity[T : DType, dim : Int](Hittable):
    """
    The needed data from hittable entities to trace them.
    """
    var geometry : Geometry[T, dim]
    var material : Material[T, dim]
    var position : Point[T, dim]

    fn aabb[T : DType, dim : Int](self) -> AABB[T, dim]:
        return rebind[AABB[T, dim]](
            self.geometry.aabb[Self.T, Self.dim]() + self.position
        )

    fn hit[T : DType, dim : Int](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        mut rec: HitRecord[T, dim]
    ) -> Bool:
        var p = rebind[Point[T, dim]](self.position)
        var local_ray = r.offset(-p)
        var hit = self.geometry.hit(local_ray, ray_t, rec)
        if hit:
            rec.p += p
            rec.mat = rebind[Material[T, dim]](self.material)
            rec.hits += 1
        return hit

@value
struct BVHSplit[T: DType, dim: Int, H : Hittable](Hittable):
    var left : ArcPointer[BVHNode[T, dim, H]]
    var right : ArcPointer[BVHNode[T, dim, H]]

    fn aabb[T : DType, dim : Int](self) -> AABB[T, dim]:
        var box = self.left[].aabb[Self.T, Self.dim]()
        box.merge_in(self.right[].aabb[Self.T, Self.dim]())
        return rebind[AABB[T, dim]](box)

    fn hit[T : DType, dim : Int](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        mut rec: HitRecord[T, dim]
    ) -> Bool:
        var hit_left = self.left[].hit(r, ray_t, rec)
        var hit_right = self.right[].hit(
            r,
            Interval(ray_t.min, rec.t if hit_left else ray_t.max), # If hit on left, limit right ray_t max to hit point on left
            rec
        )
        return hit_left or hit_right

@value
struct BVHNode[T: DType, dim: Int, H : Hittable](Hittable):
    alias Variant = Variant[
        BVHSplit[T, dim, H], 
        H]
    var _wrapped: Self.Variant
    var box : AABB[T, dim]

    fn count_hittables(self) -> Int:
        if self._wrapped.isa[BVHSplit[T, dim, H]]():
            return self._wrapped[BVHSplit[T, dim, H]].left[].count_hittables() + self._wrapped[BVHSplit[T, dim, H]].right[].count_hittables()
        else:
            return 1

    fn count_nodes(self) -> Int:
        if self._wrapped.isa[BVHSplit[T, dim, H]]():
            return 1 + self._wrapped[BVHSplit[T, dim, H]].left[].count_hittables() +  self._wrapped[BVHSplit[T, dim, H]].right[].count_hittables()
        else:
            return 0

    fn aabb[T : DType, dim : Int](self) -> AABB[T, dim]:
        return rebind[AABB[T, dim]](self.box)

    fn hit[T : DType, dim : Int](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        mut rec: HitRecord[T, dim]
    ) -> Bool:
        var r_int = rebind[Ray[Self.T, Self.dim]](r)
        var ray_t_int = rebind[Interval[Self.T]](ray_t)
        if not self.box.any_hit(r_int, ray_t_int):
            return False
        if self._wrapped.isa[BVHSplit[T, dim, H]]():
            return self._wrapped[BVHSplit[T, dim, H]].hit(r, ray_t, rec)
        else:
            return self._wrapped[H].hit(r, ray_t, rec)



fn build_bvh_nodes_recursive[
    T: DType, dim: Int, H : Hittable
](
    hittables : List[H],
    box_cache : List[AABB[T, dim]],
    mut entities: List[Int],
    start: Int,
    end: Int,
) raises -> BVHNode[T, dim, H]:
    """
    Construct a BVH node from a list of entities.
    """

    # Build the bounding box of the span of source objects.
    var bbox = AABB[T, dim]()
    for i in range(start, end):
        bbox.merge_in(box_cache[i])

    var axis = bbox.longest_axis()
    var span = end - start

    if span == 1:
        return BVHNode[T, dim, H](hittables[start],  bbox)
    else:
        # Sort to entities along the longest axis
        @parameter
        fn cmp(entity_a: EntityID, entity_b: EntityID) -> Bool:
            return box_cache[entity_a].center()[axis] < box_cache[entity_b].center()[axis]

        # Sort the entities along the longest axis within this span
        var slice = entities[start:end]
        sort[cmp](slice)

        # Prevent parametric cleanup...
        _ = axis

        var mid = start + span // 2

        # Recursively build the left and right child nodes
        var left_child = build_bvh_nodes_recursive[T, dim, H](
            hittables, box_cache, entities, start, mid
        )
        var right_child = build_bvh_nodes_recursive[T, dim, H](
            hittables, box_cache, entities, mid, end
        )
        return BVHNode[T, dim, H](
            BVHSplit[T, dim](left_child, right_child),
            bbox
        )

fn construct_bvh_list[
    T: DType, dim: Int, H : Hittable
](hittables: List[H]) raises -> BVHNode[T, dim, H]:
    """
    Construct a BVH from the given list of hittable entities.
    """
    var indices = List[Int](len(hittables))
    var box_cache = List[AABB[T, dim]]()
    for i in range(len(hittables)):
        indices.append(i)
        box_cache.append(hittables[i].aabb[T, dim]())
    return build_bvh_nodes_recursive[T, dim](
        hittables,
        box_cache,
        indices,
        0,
        len(indices),
    )

fn construct_bvh_store[
    T: DType, dim: Int
](store: ComponentStore[T, dim]) raises -> BVHNode[T, dim, HittableEntity[T, dim]]:
    """
    ECS 'system' to construct a BVH from all components in store with position and geometry.
    Returns the root entity ID of the BVH.
    """
    print("Constructing BVH...")
    # Get all entities with position and geometry components
    var entity_ids = store.get_entities_with_components(
        ComponentType.Position | ComponentType.Geometry
    )

    var hittables = List[HittableEntity[T, dim]]()
    for entity_id in entity_ids:
        var geometry = store.geometry_components[
            store.entity_to_components[entity_id[]][ComponentType.Geometry]
        ]
        var material = store.material_components[
            store.entity_to_components[entity_id[]][ComponentType.Material]
        ]
        var position = store.position_components[
            store.entity_to_components[entity_id[]][ComponentType.Position]
        ]
        hittables.append(HittableEntity(geometry, material, position))


    var root = construct_bvh_list[T, dim, HittableEntity[T, dim]](hittables)
    print("Constructed BVH!")
    return root
