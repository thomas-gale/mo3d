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
    var _center: Ray[T, dim]
    var _radius: Scalar[T]
    var _mat: Material[T, dim]  # TODO: this will be moved to my ECS shortly
    var _bounding_box: AABB[T, dim] # TODO: As will this ^^


    fn __init__(
        inout self,
        center: Point[T, dim],
        radius: Scalar[T],
        mat: Material[T, dim],
    ):
        """
        Stationary sphere with a given center and radius.
        """
        self._center = Ray[T, dim](center, Vec[T, dim]())
        self._radius = radius
        self._mat = mat

        # TODO Refactor 
        var rvec = Vec[T, dim](self._radius)
        var b1 = AABB[T, dim](
            self._center.at(0) - rvec,
            self._center.at(0) + rvec,
        )
        var b2 = AABB[T, dim](
            self._center.at(1) - rvec,
            self._center.at(1) + rvec,
        )
        self._bounding_box = AABB[T, dim](b1, b2)

    fn __init__(
        inout self,
        center1: Point[T, dim],
        center2: Point[T, dim],
        radius: Scalar[T],
        mat: Material[T, dim],
    ):
        """
        Moving sphere with a given center, radius, and color.
        """
        self._center = Ray[T, dim](center1, center2 - center1)
        self._radius = radius
        self._mat = mat

        # TODO Refactor 
        var rvec = Vec[T, dim](self._radius)
        var b1 = AABB[T, dim](
            self._center.at(0) - rvec,
            self._center.at(0) + rvec,
        )
        var b2 = AABB[T, dim](
            self._center.at(1) - rvec,
            self._center.at(1) + rvec,
        )
        self._bounding_box = AABB[T, dim](b1, b2)

    fn hit(
        self,
        r: Ray[T, dim],
        ray_t: Interval[T],
        inout rec: HitRecord[T, dim],
    ) -> Bool:
        var current_center = self._center.at(r.tm)
        var oc = current_center - r.orig
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
        var outward_normal = (rec.p - current_center) / self._radius
        rec.set_face_normal(r, outward_normal)
        rec.mat = self._mat

        return True


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
