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

from python import Python
from python import PythonObject

struct Sphere[T: DType, dim: Int](Copyable, Hittable, ImplicitlyCopyable, Movable):
    """
    A n-dimensional sphere.
    """

    var _radius: Scalar[Self.T]

    fn __init__(
        out self,
        radius: Scalar[Self.T],
    ):
        """
        Sphere defined by center position and radius.
        """
        self._radius = radius

    fn aabb(self) -> AABB[Self.T, Self.dim]:
        """
        Generate an axis-aligned bounding box for the sphere.
        """
        var rvec = Vec[Self.T, Self.dim](rebind[Scalar[Self.T]](self._radius))
        return AABB[Self.T, Self.dim](
            -rvec,
            rvec,
        )

    fn hit(
        self,
        r: Ray[Self.T, Self.dim],
        var ray_t: Interval[Self.T],
        inout rec: HitRecord[Self.T, Self.dim]
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

        rec.t = rebind[Scalar[Self.T]](root)
        rec.p = r.at(rec.t)
        var outward_normal = rec.p / rebind[Scalar[Self.T]](self._radius)
        rec.set_face_normal(r, outward_normal)

        return True

    fn __str__(self) -> String:
        return "Sphere(radius=" + str(self._radius) + ")"

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data = Python.dict()
        data["radius"] = self._radius
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        return Sphere[Self.T, Self.dim](
            float(py_obj["radius"]).cast[Self.T]())
