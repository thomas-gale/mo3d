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

from mo3d.geometry.geometry import Hittable

# This ia based on the interesection cde in Ray Tracing the 
# next week https://raytracing.github.io/books/RayTracingTheNextWeek.html#quadrilaterals

# We always work in 3 dimensios so want a version that does not raise
fn cross_3_safe[T: DType](lhs : Vec[T, 3], rhs : Vec[T, 3]) -> Vec[T, 3]:
    return Vec[T, 3](
        lhs._data[1] * rhs._data[2] - lhs._data[2] * rhs._data[1],
            lhs._data[2] * rhs._data[0] - lhs._data[0] * rhs._data[2],
            lhs._data[0] * rhs._data[1] - lhs._data[1] * rhs._data[0])

@value
struct Triangle[T: DType](Hittable):
    """
    A 3-d triangle (this is not generic as we can take some reductions in 3-d)
    which wwe cant for general simplexes as cross products only exist in 
    dimensions 1,2,3 and 7.
    """
    # The definition fo the plane - w is in the direction of the normal
    var base_point : Vec[T, 3]
    var w : Vec[T, 3]
    # Coord system such that the trinalge is in canonical form
    var u : Vec[T, 3]
    var v : Vec[T, 3]

    fn __init__(
        inout self,
        a: Vec[T, 3],
        b: Vec[T, 3],
        c: Vec[T, 3],
    ) raises :
        """
        Triangle defined by 3 points (rasis if degenerate).
        """
        self.base_point = a
        self.u = b - a
        self.v = c - a
        var normal = cross_3_safe(b- a, c - a)
        if normal.length_squared() < 1e-10:
            raise Error("Degerate triangle.")
        self.w = normal / normal.length_squared()


    fn aabb[T: DType, dim : Int](self) -> AABB[T, dim]:
        """
        Generate an axis-aligned bounding box for the triangle.
        """
        var b = (self.base_point + self.u)
        var c = (self.base_point + self.v)
        var box = AABB[Self.T, 3](b, c)
        box.merge_in(self.base_point)
        # If we pad less than this (in f32 we quickly hit the point we never hit the box)
        box.pad_to(1e-6)
        return rebind[AABB[T, dim]](box)

    fn hit[T: DType, dim : Int](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        inout rec: HitRecord[T, dim]
    ) -> Bool:
        # Get intersection with the plane
        var ray_in = rebind[Ray[Self.T, 3]](r)
        var ray_t_in = rebind[Interval[Self.T]](ray_t)
        var denom = self.w.dot(ray_in.dir)
        if math.abs(denom) < 1e-8:
            return False
        var rel = self.base_point - ray_in.orig
        var t = self.w.dot(rel) / denom
        if not ray_t_in.contains(t):
            return False
        # Get local hit point and see if hits the triangle
        var p = ray_in.at(t)
        var local_int = p - self.base_point
        var u = self.w.dot(cross_3_safe(local_int, self.v))
        var v = self.w.dot(cross_3_safe(self.u, local_int))
        if (u < 0) or (v < 0) or (u + v > 1):
            return False
        rec.t = rebind[Scalar[T]](t)
        rec.p = rebind[Point[T, dim]](p)
        rec.set_face_normal(r, rebind[Vec[T, dim]](self.w.unit()))
        return True

    fn __str__(self) -> String:
        return "Triangle(a=" + str(self.base_point) 
          + ", b=" + str(self.base_point + self.u)
          + ", c=" + str(self.base_point + self.v) + ")"
