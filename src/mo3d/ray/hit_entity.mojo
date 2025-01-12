from mo3d.math.interval import Interval
from mo3d.geometry.aabb import AABB
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import ComponentType
from mo3d.ecs.component_store import ComponentStore
from mo3d.scene.construct_bvh import BVHNode, BVHSplit, Hittable

fn hit_entity[
    T: DType, dim: Int
](
    bvh_node : BVHNode[T, dim],
    r: Ray[T, dim],
    owned ray_t: Interval[T],
    inout rec: HitRecord[T, dim],
) -> Bool:
    """
    ECS 'system' to intersect a ray with an entity in the component store.
    """
    if not bvh_node.box.any_hit(r, ray_t):
        return False
    # Is the entity a BVH or Leaf Geometry?
    if bvh_node._wrapped.isa[BVHSplit[T, dim]]():
        return hit_bvh(bvh_node._wrapped[BVHSplit[T, dim]], r, ray_t, rec)
    elif bvh_node._wrapped.isa[Hittable[T, dim]]():
        return hit_hittable(bvh_node._wrapped[Hittable[T, dim]], r, ray_t, rec)
    else:
        print("bvh_node is unhitable")
        return False


fn hit_bvh[
    T: DType, dim: Int
](
    bvh : BVHSplit[T, dim],
    r: Ray[T, dim],
    owned ray_t: Interval[T],
    inout rec: HitRecord[T, dim],
) -> Bool:
    """
    Hit a ray again a split bvh node.
    """
    rec.hits += 1

    var hit_left = hit_entity(bvh.left[], r, ray_t, rec)
    var hit_right = hit_entity(
        bvh.right[],
        r,
        Interval(ray_t.min, rec.t if hit_left else ray_t.max), # If hit on left, limit right ray_t max to hit point on left
        rec,
    )
    return hit_left or hit_right


fn hit_hittable[
    T: DType, dim: Int
](
    hittable : Hittable[T, dim],
    r: Ray[T, dim],
    owned ray_t: Interval[T],
    inout rec: HitRecord[T, dim],
) -> Bool:
    """
    Hit a ray against hitable geometry / material pair.
    """
    var local_ray = r.offset(-hittable.position)
    if hittable.orientation:
        local_ray = local_ray.rotate(hittable.orientation.value())
    var hit = hittable.geometry.hit(local_ray, ray_t, rec)
    if hit:
        if hittable.orientation:
            rec.p = hittable.orientation.value().mul_transpose(rec.p)
            rec.normal = hittable.orientation.value().mul_transpose(rec.normal)
        rec.p += hittable.position
        rec.mat = hittable.material
        rec.hits += 1
    return hit
