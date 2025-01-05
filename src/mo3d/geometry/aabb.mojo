from collections import InlineArray

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray

from mo3d.ray.hit_record import HitRecord

@always_inline
fn sign[T: DType](num : Scalar[T]) -> Scalar[T]:
    if num < 0:
        return -1
    else:
        return 1

@value
struct AABB[T: DType, dim: Int]:
    var _bounds: InlineArray[Interval[T, 1], dim]

    fn __init__(inout self):
        self._bounds = InlineArray[Interval[T, 1], dim](Interval[T, 1]())

    fn __init__(inout self, a: Point[T, dim], b: Point[T, dim]):
        self._bounds = InlineArray[Interval[T, 1], dim](
            unsafe_uninitialized=True
        )
        for i in range(dim):
            if a[i] < b[i]:
                self._bounds[i] = Interval[T, 1](a[i], b[i])
            else:
                self._bounds[i] = Interval[T, 1](b[i], a[i])

    fn __init__(inout self, owned box_a: Self, owned box_b: Self):
        self._bounds = InlineArray[Interval[T, 1], dim](
            unsafe_uninitialized=True
        )
        for i in range(dim):
            self._bounds[i] = Interval[T, 1](box_a._bounds[i], box_b._bounds[i])

    fn __add__(self, vec: Vec[T, dim]) -> Self:
        var new_box = Self()
        for i in range(dim):
            new_box._bounds[i] = self._bounds[i] + vec[i]
        return new_box

    fn clone(self) -> Self:
        var new_box = Self()
        for i in range(dim):
            new_box._bounds[i] = self._bounds[i]
        return new_box

    fn axis_interval(self, n: Int) -> Interval[T, 1]:
        if n < 0 or n >= dim:
            print("Invalid axis index")
            return Interval[T, 1]()
        return self._bounds[n]

    fn longest_axis(self) -> Int:
        # Returns the index of the longest axis of the bounding box.
        var longest_size: Scalar[T] = 0
        var longest_axis = 0
        for i in range(dim):
            var size = self._bounds[i].size()
            if size > longest_size:
                longest_size = size
                longest_axis = i
        return longest_axis

    fn compare[axis: Int](self, other: Self) -> Bool:
        """
        Compare the bounding box min along the given axis.
        """
        return self._bounds[axis].min < other._bounds[axis].min

    # Ideally use some form of parameterisation to make the recording optional
    fn any_hit(self, r: Ray[T, dim], owned ray_t: Interval[T, 1]) -> Bool:
        """
        Check if the ray intersects the bounding box.
        """
        @parameter
        for axis in range(dim):
            var ax = self.axis_interval(axis)
            var adinv = 1.0 / r.dir[axis]

            var t0 = (ax.min - r.orig[axis]) * adinv
            var t1 = (ax.max - r.orig[axis]) * adinv

            if t0 < t1:
                if t0 > ray_t.min:
                    ray_t.min = t0
                if t1 < ray_t.max:
                    ray_t.max = t1
            else:
                if t1 > ray_t.min:
                    ray_t.min = t1
                if t0 < ray_t.max:
                    ray_t.max = t0
            
            if ray_t.max <= ray_t.min:
                return False
        return True

    fn hit(self, r: Ray[T, dim], owned ray_t: Interval[T, 1], inout rec: HitRecord[T, dim]) -> Bool:
        """
        Check if the ray intersects the bounding box.
        """
        var min_axis = -1
        var max_axis = -1
        @parameter
        for axis in range(dim):
            var ax = self.axis_interval(axis)
            var adinv = 1.0 / r.dir[axis]

            var t0 = (ax.min - r.orig[axis]) * adinv
            var t1 = (ax.max - r.orig[axis]) * adinv

            if t0 < t1:
                if t0 > ray_t.min:
                    ray_t.min = t0
                    min_axis = axis
                if t1 < ray_t.max:
                    ray_t.max = t1
                    max_axis = axis
            else:
                if t1 > ray_t.min:
                    ray_t.min = t1
                    min_axis = axis
                if t0 < ray_t.max:
                    ray_t.max = t0
                    max_axis = axis
            
            if ray_t.max <= ray_t.min:
                return False
        if min_axis >= 0:
            rec.t = ray_t.min
            rec.p = r.at(rec.t)
            var normal = Vec[T, dim]()
            normal[min_axis] = sign(rec.p[min_axis])
            rec.set_face_normal(r, normal)
            return True
        elif max_axis >= 0:
            rec.t = ray_t.max
            rec.p = r.at(rec.t)
            var normal = Vec[T, dim]()
            normal[max_axis] = sign(rec.p[max_axis])
            rec.set_face_normal(r, normal)
            return True
        else:
            return False

    fn __str__(self) -> String:
        var s: String = "AABB("
        for i in range(dim):
            s += str(self._bounds[i])
            if i < dim - 1:
                s += ", "
        s += ")"
        return s
