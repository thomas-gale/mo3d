from testing import assert_equal

from mo3d.math.vec4 import Vec4
from mo3d.math.point4 import Point4
from mo3d.ray.ray4 import Ray4


fn test_create_empty_ray() raises:
    var r = Ray4[DType.float32]()

    var p = Point4[DType.float32]()
    var v = Vec4[DType.float32]()

    assert_equal(r.orig, p)
    assert_equal(r.dir, v)
