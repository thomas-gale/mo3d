from utils import Variant

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.geometry.sphere import Sphere
from mo3d.geometry.aabb import AABB


@value
struct Hittable[T: DType, dim: Int]:
    alias Variant = Variant[Sphere[T, dim]]
    var _hittable: Self.Variant
    var _bounding_box: AABB[T, dim]

    fn __init__(inout self, hittable: Self.Variant) raises:
        if hittable.isa[Sphere[T, dim]]():
            self._hittable = hittable
            var rvec = Vec[T, dim](hittable[Sphere[T, dim]]._radius)
            self._bounding_box = AABB[T, dim](
                hittable[Sphere[T, dim]]._center.orig - rvec,
                hittable[Sphere[T, dim]]._center.orig + rvec,
            )
        else:
            raise Error("Unsupported hittable type")

    fn hit(
        self,
        r: Ray[T, dim],
        ray_t: Interval[T],
        inout rec: HitRecord[T, dim],
    ) raises -> Bool:
        if self._hittable.isa[Sphere[T, dim]]():
            return self._hittable[Sphere[T, dim]].hit(r, ray_t, rec)
        else:
            raise Error("Unsupported hittable type")
