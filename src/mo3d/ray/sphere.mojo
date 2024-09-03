from math import sqrt

from mo3d.math.interval import Interval
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord


@value
struct Sphere[T: DType, dim: Int]:
    var _center: Point[T, dim]
    var _radius: Scalar[T]

    fn __init__(
        inout self, center: Point[T, dim], radius: Scalar[T]
    ):
        self._center = center
        self._radius = radius

    fn hit(
        self,
        r: Ray[T, dim],
        ray_t: Interval[T],
        inout rec: HitRecord[T, dim],
    ) -> Bool:
        var oc = self._center - r.orig
        var a = r.dir.length_squared()
        var h = r.dir.dot(oc)
        var c = oc.length_squared() - self._radius * self._radius

        var discriminant = h * h - a * c
        if discriminant < 0:
            return False

        var sqrtd = sqrt(discriminant)

        # Find the nearest root that lies in the acceptable range.
        var root = (h - sqrtd) / a
        if not ray_t.surrounds(root):
            root = (h + sqrtd) / a
            if not ray_t.surrounds(root):
                return False

        rec.t = root
        rec.p = r.at(rec.t)
        var outward_normal = (rec.p - self._center) / self._radius
        rec.set_face_normal(r, outward_normal)

        return True


fn hit_sphere[
    T: DType,
    dim: Int
](
    center: Point[T, dim], radius: Scalar[T], r: Ray[T, dim]
) -> Scalar[T]:
    var oc = center - r.orig
    var a = r.dir.length_squared()
    var h = r.dir.dot(oc)
    var c = oc.length_squared() - radius * radius
    var discriminant = h * h - a * c

    if discriminant < 0:
        return -1.0
    else:
        return (h - sqrt(discriminant)) / a
