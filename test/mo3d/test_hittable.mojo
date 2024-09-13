from testing import assert_equal

from mo3d.math.point import Point
from mo3d.ray.hittable import Hittable
from mo3d.geometry.sphere import Sphere


fn test_create_sphere_hittable() raises:
    var hittable_sphere = Hittable[DType.float32, 3](Sphere(Point[DType.float32, 3](1.0, 2.0, 3.0), 1.0))

    assert_equal(hittable_sphere._hittable.isa[Sphere[DType.float32, 3]](), True)
    assert_equal(hittable_sphere._hittable[Sphere[DType.float32, 3]]._center, Point[DType.float32, 3](1.0, 2.0, 3.0))
    assert_equal(hittable_sphere._hittable[Sphere[DType.float32, 3]]._radius, 1.0)
