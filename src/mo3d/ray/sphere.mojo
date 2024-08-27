from math import sqrt

from mo3d.precision import float_type
from mo3d.math.point4 import Point4
from mo3d.ray.ray4 import Ray4
from mo3d.ray.hittable import HitRecord, Hittable


@value
struct Sphere(Hittable):
    var _center: Point4[float_type]
    var _radius: Scalar[float_type]

    fn __init__(
        inout self, center: Point4[float_type], radius: Scalar[float_type]
    ):
        self._center = center
        self._radius = radius

    fn hit(
        self,
        r: Ray4[float_type],
        ray_tmin: Scalar[float_type],
        ray_tmax: Scalar[float_type],
        inout rec: HitRecord[float_type],
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
        if root <= ray_tmin or ray_tmax <= root:
            root = (h + sqrtd) / a
            if root <= ray_tmin or ray_tmax <= root:
                return False

        rec.t = root
        rec.p = r.at(rec.t)
        var outward_normal = (rec.p - self._center) / self._radius
        rec.set_face_normal(r, outward_normal)

        return True


fn hit_sphere[
    float_type: DType
](
    center: Point4[float_type], radius: Scalar[float_type], r: Ray4[float_type]
) -> Scalar[float_type]:
    var oc = center - r.orig
    var a = r.dir.length_squared()
    var h = r.dir.dot(oc)
    var c = oc.length_squared() - radius * radius
    var discriminant = h * h - a * c

    if discriminant < 0:
        return -1.0
    else:
        return (h - sqrt(discriminant)) / a
