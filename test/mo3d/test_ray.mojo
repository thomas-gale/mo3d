from testing import assert_equal

from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray


fn test_create_empty_ray() raises:
    var r = Ray[DType.float32, 3]()

    var p = Point[DType.float32, 3]()
    var v = Vec[DType.float32, 3]()

    assert_equal(r.orig, p)
    assert_equal(r.dir, v)
