from collections import InlineArray

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray

from mo3d.geometry.geometry import Hittable

from mo3d.ray.hit_record import HitRecord

from python import Python
from python import PythonObject

@always_inline
fn sign[T: DType](num : Scalar[T]) -> Scalar[T]:
    if num < 0:
        return -1
    else:
        return 1

@value
struct AABB[T: DType, dim: Int](Hittable):
    var _bounds: InlineArray[Interval[T, 1], dim]

    fn __init__(inout self):
        self._bounds = InlineArray[Interval[T, 1], dim](Interval[T, 1]())

    fn __init__(inout self, a: Point[T, dim], b: Point[T, dim]):
        self._bounds = InlineArray[Interval[T, 1], dim](
            unsafe_uninitialized=True
        )
        @parameter
        for i in range(dim):
            if a[i] < b[i]:
                self._bounds[i] = Interval[T, 1](a[i], b[i])
            else:
                self._bounds[i] = Interval[T, 1](b[i], a[i])

    fn __init__(inout self, owned box_a: Self, owned box_b: Self):
        self._bounds = InlineArray[Interval[T, 1], dim](
            unsafe_uninitialized=True
        )
        @parameter
        for i in range(dim):
            self._bounds[i] = Interval[T, 1](box_a._bounds[i], box_b._bounds[i])

    fn __add__(self, vec: Vec[T, dim]) -> Self:
        var new_box = Self()
        @parameter
        for i in range(dim):
            new_box._bounds[i] = self._bounds[i] + vec[i]
        return new_box

    fn center(self) -> Vec[T, dim]:
        var res = Vec[T, dim](0)
        @parameter
        for i in range(dim):
            res[i] = self._bounds[i].mid()
        return res
 
    fn clone(self) -> Self:
        var new_box = Self()
        @parameter
        for i in range(dim):
            new_box._bounds[i] = self._bounds[i]
        return new_box

    fn merge_in(inout self, vec : Vec[T, dim]):
        @parameter
        for i in range(dim):
            self._bounds[i].merge_in(vec[i])

    fn merge_in(inout self, aabb : AABB[T, dim]):
        @parameter
        for i in range(dim):
            self._bounds[i].merge_in(aabb._bounds[i])

    fn pad_to(inout self, min : Scalar[T]):
        @parameter
        for i in range(dim):
            if (self._bounds[i].size() < min):
                self._bounds[i] = self._bounds[i].expand(min / 2)


    fn axis_interval(self, n: Int) -> Interval[T, 1]:
        if n < 0 or n >= dim:
            print("Invalid axis index")
            return Interval[T, 1]()
        return self._bounds[n]

    fn longest_axis(self) -> Int:
        # Returns the index of the longest axis of the bounding box.
        var longest_size: Scalar[T] = 0
        var longest_axis = 0
        @parameter
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

    fn aabb[T: DType, dim: Int](self) -> AABB[T,dim]:
        return rebind[AABB[T, dim]](self)

    fn hit[T: DType, dim: Int](self, r: Ray[T, dim], owned ray_t: Interval[T, 1], inout rec: HitRecord[T, dim]) -> Bool:
        """
        Check if the ray intersects the bounding box.
        """
        var ray_in = rebind[Ray[Self.T, Self.dim]](r)
        var ray_t_in = rebind[Interval[Self.T]](ray_t)
        var min_axis = -1
        var max_axis = -1
        @parameter
        for axis in range(dim):
            var ax = self.axis_interval(axis)
            var adinv = 1.0 / ray_in.dir[axis]

            var t0 = (ax.min - ray_in.orig[axis]) * adinv
            var t1 = (ax.max - ray_in.orig[axis]) * adinv

            if t0 < t1:
                if t0 > ray_t_in.min:
                    ray_t_in.min = t0
                    min_axis = axis
                if t1 < ray_t_in.max:
                    ray_t_in.max = t1
                    max_axis = axis
            else:
                if t1 > ray_t_in.min:
                    ray_t_in.min = t1
                    min_axis = axis
                if t0 < ray_t_in.max:
                    ray_t_in.max = t0
                    max_axis = axis
            
            if ray_t.max <= ray_t.min:
                return False
        if min_axis >= 0:
            rec.t = rebind[Scalar[T]](ray_t_in.min)
            rec.p = r.at(rec.t)
            var normal = Vec[T, dim]()
            normal[min_axis] = sign(rec.p[min_axis])
            rec.set_face_normal(r, normal)
            return True
        elif max_axis >= 0:
            rec.t = rebind[Scalar[T]](ray_t_in.max)
            rec.p = r.at(rec.t)
            var normal = Vec[T, dim]()
            normal[max_axis] = sign(rec.p[max_axis])
            rec.set_face_normal(r, normal)
            return True
        else:
            return False

    fn max_pt(self) -> Point[T, dim]:
        var pt = Point[T, dim]()
        @parameter
        for i in range(dim):
            pt[i] = self._bounds[i].max
        return pt

    fn min_pt(self) -> Point[T, dim]:
        var pt = Point[T, dim]()
        @parameter
        for i in range(dim):
            pt[i] = self._bounds[i].min
        return pt

    fn __str__(self) -> String:
        var s: String = "AABB("
        for i in range(dim):
            s += str(self._bounds[i])
            if i < dim - 1:
                s += ", "
        s += ")"
        return s

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data = Python.dict()
        data["min"] = self.min_pt()._dump_py_json()
        data["max"] = self.max_pt()._dump_py_json()
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        return AABB[T,dim](
            Point[T, dim]._load_py_json(py_obj["min"]),
            Point[T, dim]._load_py_json(py_obj["max"]))
