from utils import Variant

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord
from mo3d.ray.hittable_list import HittableList
from mo3d.ray.bvh_node import BVHNode

from mo3d.geometry.sphere import Sphere
from mo3d.geometry.aabb import AABB


@value
struct Hittable[T: DType, dim: Int](CollectionElement):
    alias Variant = Variant[Sphere[T, dim], BVHNode[T, dim]]
    var _hittable: Self.Variant

    fn __init__(inout self, hittable: Self.Variant) raises:
        if hittable.isa[Sphere[T, dim]]():
            self._hittable = hittable
        elif hittable.isa[BVHNode[T, dim]]():
            self._hittable = hittable
        else:
            raise Error("Hittable c'tor: Unsupported hittable type")

    fn hit(
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        inout rec: HitRecord[T, dim],
    ) -> Bool:
        if self._hittable.isa[Sphere[T, dim]]():
            return self._hittable[Sphere[T, dim]].hit(r, ray_t, rec)
        elif self._hittable.isa[BVHNode[T, dim]]():
            return self._hittable[BVHNode[T, dim]].hit(r, ray_t, rec)
        else:
            print("Hittable hit: Unsupported hittable type")
            return False

    fn bounding_box(self) -> AABB[T, dim]:
        if self._hittable.isa[Sphere[T, dim]]():
            # return self._hittable[Sphere[T, dim]]._bounding_box
            return AABB[T, dim]()
        elif self._hittable.isa[BVHNode[T, dim]]():
            return self._hittable[BVHNode[T, dim]]._bbox
        else:
            print("Hittable bounding_box: Unsupported hittable type")
            return AABB[T, dim]()
