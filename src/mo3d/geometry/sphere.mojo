from math import sqrt

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.color4 import Color4
from mo3d.ray.hit_record import HitRecord

from mo3d.geometry.aabb import AABB
from mo3d.geometry.geometry import Hittable

from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian


@value
struct Sphere[T: DType, dim: Int](Hittable):
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

    fn aabb[T : DType, dim : Int](self) -> AABB[T, dim]:
        """
        Generate an axis-aligned bounding box for the sphere.
        """
        var rvec = Vec[T, dim](rebind[Scalar[T]](self._radius))
        return AABB[T, dim](
            -rvec,
            rvec,
        )

    fn hit[T : DType, dim : Int](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        inout rec: HitRecord[T, dim]
    ) -> Bool:
        var ray_in = rebind[Ray[Self.T, Self.dim]](r)
        var ray_t_in = rebind[Interval[Self.T]](ray_t)
        var a = ray_in.dir.length_squared()
        var h = ray_in.dir.dot(-ray_in.orig)
        var c = ray_in.orig.length_squared() - self._radius * self._radius

        var discriminant = h * h - a * c
        if discriminant < 0:
            return False

        var sqrtd = sqrt(discriminant)

        # Find the nearest root that lies in the acceptable range.
        var root = (h - sqrtd) / a
        if not ray_t_in.surrounds(root):
            root = (h + sqrtd) / a
            if not ray_t_in.surrounds(root):
                return False

        rec.t = rebind[Scalar[T]](root)
        rec.p = r.at(rec.t)
        var outward_normal = rec.p / rebind[Scalar[T]](self._radius)
        rec.set_face_normal(r, outward_normal)

        return True

    fn __str__(self) -> String:
        return "Sphere(radius=" + str(self._radius) + ")"
