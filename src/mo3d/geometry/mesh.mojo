from memory.arc import ArcPointer
from memory.unsafe_pointer import UnsafePointer
from collections.inline_array import InlineArray

from collections.list import List

from mo3d.math.vec import Vec
from mo3d.math.interval import Interval
from mo3d.geometry.triangle import Triangle
from mo3d.geometry.geometry import Hittable
from mo3d.geometry.aabb import AABB
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

import os

@value
struct Mesh[T : DType](Hittable):
    var _triangles : ArcPointer[List[Triangle[T]]]

    fn __init__(out self, owned triangles : List[Triangle[T]]) raises:
        self._triangles = ArcPointer(triangles)

    @staticmethod
    fn load_from_binary_stl(filename : String) raises -> Mesh[T]: 
        var file = open(filename, "r")
        # Header
        _ = file.seek(80)
        var size_ptr = UnsafePointer[UInt32].alloc(1)
        _ = file.read(size_ptr, 1)
        var size = size_ptr[]

        var tris = List[Triangle[T]]()

        for _ in range(size):
            # Skip normal for now 
            see = file.seek(12, os.SEEK_CUR)
            print(see)
            var vert_a_ptr = UnsafePointer[Float32].alloc(3)
            var vert_b_ptr = UnsafePointer[Float32].alloc(3)
            var vert_c_ptr = UnsafePointer[Float32].alloc(3)
            _ = file.read(vert_a_ptr, 3)
            _ = file.read(vert_b_ptr, 3)
            _ = file.read(vert_c_ptr, 3)
            var a = Vec[T, 3](vert_a_ptr[0].cast[T](), vert_a_ptr[1].cast[T](), vert_a_ptr[2].cast[T]())
            var b = Vec[T, 3](vert_b_ptr[0].cast[T](), vert_b_ptr[1].cast[T](), vert_b_ptr[2].cast[T]())
            var c = Vec[T, 3](vert_c_ptr[0].cast[T](), vert_c_ptr[1].cast[T](), vert_c_ptr[2].cast[T]())
            try:
                var t = Triangle[T](a, b, c)
                print("Triangle: " +str(t))
                tris.append(t)
            except:
                print("Degenerate triangle skipped")
            # Skip tag 
            _ = file.seek(2, os.SEEK_CUR)

        print("Loaded " + str(len(tris)) + " triangles from " + str(filename))

        return Mesh[T](tris)


    fn aabb[T : DType, dim : Int](self) -> AABB[T, dim]:
        var box = AABB[T, 3]()
        for tri in self._triangles[]:
            box.merge_in(tri[].aabb[T, 3]())
        return rebind[AABB[T, dim]](box)

    fn hit[T : DType, dim : Int](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        inout rec: HitRecord[T, dim]
    ) -> Bool:
        var any_hit = False
        for tri in self._triangles[]:
            var res = tri[].hit[T, dim](r, ray_t, rec)
            if res:
                ray_t.max = rec.t
                any_hit = True
        return any_hit


    fn __str__(self) -> String:
        return "Mesh with (" + str(len(self._triangles[])) + ") triangles"