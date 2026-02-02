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
    """ 
    A mesh this is a BVH of triangles. No vertex mapping is currently
    done to store vertex normals or UV coords so far.

    The triangles are stored in a specialized BVH for faster tracing.
    """
    var _triangles : BVHNode[T, 3, Triangle[T]]

    fn __init__(out self, owned triangles : List[Triangle[T]]) raises:
        self._triangles = construct_bvh_list[T, 3, Triangle[T]](triangles)

    @staticmethod
    fn load_from_binary_stl(filename : String, scale : Scalar[T] = 1.0) raises -> Mesh[T]:
        """
        Load the triangle mesh from a binary STL file excluding any degenerate
        triangles.

        As STL files are in uncertain units a scale factor is added to apply to
        the vertices for convienience.

        Will raise if file cannot be parsed.
        """
        var file = open(filename, "r")
        # Header
        _ = file.seek(80)
        var size = InlineArray[UInt32, 1](0)
        _ = file.read(size.unsafe_ptr().bitcast[UInt8](), 1 * sizeof[UInt32]())

        var tris = List[Triangle[T]]()

        for _ in range(size[0]):
            # Skip normal for now 
            see = file.seek(12, os.SEEK_CUR)
            var vert_a = InlineArray[Float32, 3](0)
            var vert_b = InlineArray[Float32, 3](0)
            var vert_c = InlineArray[Float32, 3](0)
            _ = file.read(vert_a.unsafe_ptr().bitcast[UInt8](), 3 * sizeof[Float32]())
            _ = file.read(vert_b.unsafe_ptr().bitcast[UInt8](), 3 * sizeof[Float32]())
            _ = file.read(vert_c.unsafe_ptr().bitcast[UInt8](), 3 * sizeof[Float32]())
            var a = Vec[T, 3](vert_a[0].cast[T](), vert_a[1].cast[T](), vert_a[2].cast[T]())
            var b = Vec[T, 3](vert_b[0].cast[T](), vert_b[1].cast[T](), vert_b[2].cast[T]())
            var c = Vec[T, 3](vert_c[0].cast[T](), vert_c[1].cast[T](), vert_c[2].cast[T]())
            try:
                var t = Triangle[T](a * scale, b * scale, c * scale)
                tris.append(t)
            except:
                # Skip degenerate triangles
                pass
            # Skip tag 
            _ = file.seek(2, os.SEEK_CUR)
        return Mesh[Self.T](tris)


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