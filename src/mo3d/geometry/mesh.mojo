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

from mo3d.scene.construct_bvh import BVHNode, construct_bvh_list

import os

@value
struct Mesh[T : DType](Hittable):
    var _triangles : BVHNode[T, 3, Triangle[T]]

    fn __init__(out self, owned triangles : List[Triangle[T]]) raises:
        self._triangles = construct_bvh_list[T, 3, Triangle[T]](triangles)

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
                var t = Triangle[T](a * 0.1, b * 0.1, c * 0.1)
                print("Triangle: " +str(t))
                tris.append(t)
            except:
                print("Degenerate triangle skipped")
            # Skip tag 
            _ = file.seek(2, os.SEEK_CUR)

        print("Loaded " + str(len(tris)) + " triangles from " + str(filename))

        return Mesh[T](tris)


    fn aabb[T : DType, dim : Int](self) -> AABB[T, dim]:
        return self._triangles.aabb[T, dim]()

    fn hit[T : DType, dim : Int](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        inout rec: HitRecord[T, dim]
    ) -> Bool:
        return self._triangles.hit(r, ray_t, rec)


    fn __str__(self) -> String:
        return "Mesh with (" + str(self._triangles.count_hittables()) + ") triangles"