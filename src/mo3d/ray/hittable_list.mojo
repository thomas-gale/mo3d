from collections import List

from mo3d.math.interval import Interval
from mo3d.ray.hit_record import HitRecord
from mo3d.ray.hittable import Hittable
from mo3d.ray.ray import Ray

from mo3d.geometry.sphere import Sphere
from mo3d.geometry.aabb import AABB


@value
struct HittableList[T: DType, dim: Int](CollectionElement):
    """
    Basic AoS implementation for a list of hittables.
    Where each hittable is a Variant of various geometry types.
    """
    var _hittables: List[Hittable[T, dim]] # This is about to be supeceded by ECS system, its' not clear the ownership model currently.
    var _bounding_box: AABB[T, dim]

    fn __init__(inout self):
        self._hittables = List[Hittable[T, dim]]()
        self._bounding_box = AABB[T, dim]()

    fn add_hittable(inout self, hittable: Hittable[T, dim]):
        self._hittables.append(hittable)
        self._bounding_box = AABB[T, dim](self._bounding_box.clone(), hittable.bounding_box())    

    fn hit(
        self,
        r: Ray[T, dim],
        ray_t: Interval[T],
        inout rec: HitRecord[T, dim],
    ) -> Bool:
        var temp_rec = HitRecord[T, dim]()
        var hit_anything = False
        var closest_so_far = ray_t.max

        for hittable in self._hittables:
            if hittable[].hit(r, Interval(ray_t.min, closest_so_far), temp_rec):
                hit_anything = True
                closest_so_far = temp_rec.t
                rec = temp_rec

        return hit_anything
