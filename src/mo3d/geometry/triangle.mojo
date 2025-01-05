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

# This ia based on the interesection cde in Ray Tracing the 
# next week https://raytracing.github.io/books/RayTracingTheNextWeek.html#quadrilaterals

# We always work in 3 dimensios so want a version that does not raise
fn cross_3_safe[T: DType](lhs : Vec[T, 3], rhs : Vec[T, 3]) -> Vec[T, 3]:
    return Vec[T, 3](
        lhs._data[1] * rhs._data[2] - lhs._data[2] * rhs._data[1],
            lhs._data[2] * rhs._data[0] - lhs._data[0] * rhs._data[2],
            lhs._data[0] * rhs._data[1] - lhs._data[1] * rhs._data[0])

@value
struct Triangle[T: DType](CollectionElement):
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


    fn aabb(self) -> AABB[T, 3]:
        """
        Generate an axis-aligned bounding box for the sphere.
        """
        var b = (self.base_point + self.u)
        var c = (self.base_point + self.v)
        var box = AABB[T, 3](b, c)
        box.merge_in(self.base_point)
        box.pad_to(1e-8)
        return box

    fn hit(
        self,
        r: Ray[T, 3],
        owned ray_t: Interval[T],
        inout rec: HitRecord[T, 3]
    ) -> Bool:
        # Get intersection with the plane
        var denom = self.w.dot(r.dir)
        if math.abs(denom) < 1e-8:
            return False
        var t = self.w.dot(r.orig - self.base_point) / denom
        if not ray_t.contains(t):
            return False
        # Get local hit point and see if hits the triangle
        var p = r.at(t)
        var local_int = p - self.base_point
        var u = self.w.dot(cross_3_safe(local_int, self.v))
        var v = self.w.dot(cross_3_safe(self.u, local_int))
        if (u < 0) or (v < 0) or (u + v > 1):
            return False
        rec.t = t
        rec.p = p
        rec.set_face_normal(r, self.w)
        return True

    fn __str__(self) -> String:
        return "Triangle(a=" + str(self.base_point) 
          + ", b=" + str(self.base_point + self.u)
          + ", c=" + str(self.base_point + self.v) + ")"
