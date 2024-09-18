from testing import assert_equal

from mo3d.math.point import Point
from mo3d.ray.hittable import Hittable
from mo3d.ray.color4 import Color4
from mo3d.geometry.sphere import Sphere
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian


fn test_create_sphere_hittable() raises:
    alias ft = DType.float32
    # var mat = Material[ft, 3](Lambertian[ft, 3](Color4[ft](0.8, 0.8, 0.0)))
    var hittable_sphere = Hittable[ft, 3](
        Sphere(Point[ft, 3](1.0, 2.0, 3.0), 1.0)
        # Sphere(Point[ft, 3](1.0, 2.0, 3.0), 1.0, mat)
    )

    assert_equal(hittable_sphere._hittable.isa[Sphere[ft, 3]](), True)
    assert_equal(
        hittable_sphere._hittable[Sphere[ft, 3]]._center.orig,
        Point[ft, 3](1.0, 2.0, 3.0),
    )
    assert_equal(hittable_sphere._hittable[Sphere[ft, 3]]._radius, 1.0)
