from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from collections import List

from mo3d.math.point import Point
from mo3d.ray.bvh_node import BVHNode
from mo3d.ray.hittable import Hittable
from mo3d.ray.color4 import Color4

from mo3d.geometry.sphere import Sphere

from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian   

alias f32 = DType.float32

# fn test_create_empty_bvh_node() raises:
#   var hittables = List[Hittable[f32, 3]]()
#   var bvh_node = BVHNode[f32, 3](List[Hittable[f32, 3]](), 0, 0)
 
fn test_create_simple_bvh_node_2() raises:
  var mat = Material[f32, 3](
      Lambertian[f32, 3](Color4[f32](0.5, 0.5, 0.5, 1.0))
  )
  var hittables = List[Hittable[f32, 3]](
      Hittable[f32, 3](Sphere(Point[f32, 3](0, 0, 0), 1, mat)),
      Hittable[f32, 3](Sphere(Point[f32, 3](1, 0, 0), 1, mat)),
  )
  var bvh_node = BVHNode[f32, 3](hittables, 0, len(hittables))

fn test_create_simple_bvh_node_3() raises:
  var mat = Material[f32, 3](
      Lambertian[f32, 3](Color4[f32](0.5, 0.5, 0.5, 1.0))
  )
  var hittables = List[Hittable[f32, 3]](
      Hittable[f32, 3](Sphere(Point[f32, 3](0, 0, 0), 1, mat)),
      Hittable[f32, 3](Sphere(Point[f32, 3](1, 0, 0), 1, mat)),
      Hittable[f32, 3](Sphere(Point[f32, 3](-1, 0, 0), 1, mat)),
  )
  var bvh_node = BVHNode[f32, 3](hittables, 0, len(hittables))
  # assert(bvh_node._left.isa[BVHNode[f32, 3]]())