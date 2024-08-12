from testing import assert_true, assert_equal, assert_almost_equal

from mo3d.numeric import NumericFloat32
from mo3d.math import Vec3


fn test_create_vec3_float32() raises:
    var x = Vec3[NumericFloat32](x=42.0, y=43.0, z=44.0)

    assert_equal(x.x, 42.0, msg="Vec3[NumericFloat32] x component not working")
    assert_equal(x.y, 43.0, msg="Vec3[NumericFloat32] y component not working")
    assert_equal(x.z, 44.0, msg="Vec3[NumericFloat32] z component not working")
