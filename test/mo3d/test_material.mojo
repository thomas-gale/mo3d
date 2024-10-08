from testing import assert_equal, assert_true, assert_false

from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian


fn test_create_lambertian_material() raises:
    var l = Lambertian[DType.float32, 3](
        Color4[DType.float32](0.5, 0.5, 0.5, 1.0)
    )
    assert_equal(l.albedo, Color4[DType.float32](0.5, 0.5, 0.5, 1.0))
    var m = Material[DType.float32, 3](l)
    assert_true(m._mat.isa[Lambertian[DType.float32, 3]]())


fn test_lambertian_material_scatter_ray() raises:
    """
    WIP: Not sure if the Variant type is not creating a huge mess in the code... :thinking:.
    """
    var m = Material[DType.float32, 3](Lambertian[DType.float32, 3](
        Color4[DType.float32](0.5, 0.5, 0.5, 1.0)
    ))
    var hr = HitRecord[DType.float32, 3](
        Point[DType.float32, 3](),
        Vec[DType.float32, 3](0.0, 0.0, 1.0),
        m,
        1.0,
        True,
        0,
    )
    var r = Ray[DType.float32, 3](
        Point[DType.float32, 3](0.0, 0.0, 1.0),
        Vec[DType.float32, 3](0.0, 0.0, -1.0),
    )
    var r_scattered = Ray[DType.float32, 3]()
    var attenuation = Color4[DType.float32]()

    var scattered = m.scatter(
        r, hr, attenuation, r_scattered
    )

    assert_true(scattered)
    assert_equal(attenuation, Color4[DType.float32](0.5, 0.5, 0.5, 1.0))
    assert_false(r_scattered.dir.near_zero())
