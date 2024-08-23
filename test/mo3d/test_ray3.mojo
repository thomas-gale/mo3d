from testing import assert_equal

from mo3d.math.vec3 import Vec3
from mo3d.math.point3 import Point3
from mo3d.math.ray3 import Ray3


fn test_create_empty_ray() raises:
    var r = Ray3[DType.float32]()

    var p = Point3[DType.float32]()
    var v = Vec3[DType.float32]()

    # TODO
    # assert_equal(r.orig, p)
    # assert_equal(r.dir, v)
