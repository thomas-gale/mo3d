from math import sqrt

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.color4 import Color4
from mo3d.ray.hit_record import HitRecord

from mo3d.geometry.aabb import AABB

from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian


@value
struct Sphere[T: DType, dim: Int](CollectionElement):
    """
    A n-dimensional sphere.
    """

    var _radius: Scalar[T]

    fn __init__(
        inout self,
        radius: Scalar[T],
    ):
        """
        Sphere defined by center position and radius.
        """
        self._radius = radius

    fn aabb(self) -> AABB[T, dim]:
        """
        Generate an axis-aligned bounding box for the sphere.
        """
        var rvec = Vec[T, dim](self._radius)
        return AABB[T, dim](
            -rvec,
            rvec,
        )

    fn hit(
        self,
        r: Ray[T, dim],
        ray_t: Interval[T],
        inout rec: HitRecord[T, dim],
        offset: Point[T, dim],
        mat: Material[T, dim],
    ) -> Bool:
        var oc = offset - r.orig
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
        var outward_normal = (rec.p - offset) / self._radius
        rec.set_face_normal(r, outward_normal)
        rec.mat = mat

        return True

    fn __str__(self) -> String:
        return "Sphere(radius=" + str(self._radius) + ")"


fn hit_sphere[
    T: DType, dim: Int
](center: Point[T, dim], radius: Scalar[T], r: Ray[T, dim]) -> Scalar[T]:
    var oc = center - r.orig
    var a = r.dir.length_squared()
    var h = r.dir.dot(oc)
    var c = oc.length_squared() - radius * radius
    var discriminant = h * h - a * c

    if discriminant < 0:
        return -1.0
    else:
        return (h - sqrt(discriminant)) / a
