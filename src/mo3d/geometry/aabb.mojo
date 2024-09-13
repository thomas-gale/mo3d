from collections import InlineArray

from mo3d.math.interval import Interval
from mo3d.math.point import Point
from mo3d.ray.ray import Ray


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
            self._bounds[i] = Interval[T, 1](a[i], b[i])

    fn axis_interval(self, n: Int) raises -> Interval[T, 1]:
        if n < 0 or n >= dim:
            raise Error("Invalid axis index")
        return self._bounds[n]

    fn hit(self, r: Ray[T, dim], inout ray_t: Interval[T, 1]) raises -> Bool:
        for axis in range(dim):
            var ax = self.axis_interval(axis)
            var adinv = 1.0 / r.dir[axis]

            var t0 = (ax.min - r.orig[axis]) * adinv
            var t1 = (ax.max - r.dir[axis]) * adinv

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