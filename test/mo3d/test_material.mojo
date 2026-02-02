from testing import assert_equal, assert_true, assert_false

from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.texture.texture import Texture
from mo3d.texture.solid import Solid

from mo3d.random.rng import Rng

comptime f32 = DType.float32

fn test_create_lambertian_material() raises:
    var c = Color4[f32](0.5, 0.5, 0.5, 1.0)
    var albedo = Texture[f32, 3](
        Solid[f32, 3](c)
    )
    var l = Lambertian[f32, 3](
       albedo 
    )
    var m = Material[DType.float32, 3](l)
    assert_true(m._mat.isa[Lambertian[DType.float32, 3]]())


fn test_lambertian_material_scatter_ray() raises:
    """
    WIP: Not sure if the Variant type is not creating a huge mess in the code... :thinking:.
    """
    var c = Color4[f32](0.5, 0.5, 0.5, 1.0)
    var albedo = Texture[f32, 3](
        Solid[f32, 3](c)
    )
    var l = Lambertian[f32, 3](
       albedo 
    )
    var m = Material[DType.float32, 3](l)
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

    var rng = Rng(1)

    var scattered = m.scatter(
        rng, r, hr, attenuation, r_scattered
    )

    assert_true(scattered)
    assert_equal(attenuation, Color4[DType.float32](0.5, 0.5, 0.5, 1.0))
    assert_false(r_scattered.dir.near_zero())
