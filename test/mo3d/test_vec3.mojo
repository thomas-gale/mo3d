from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.math.vec3 import Vec3


fn test_create_empty_vec3_float32() raises:
    var v = Vec3[DType.float32]()

    assert_equal(v.x(), 0.0)
    assert_equal(v.y(), 0.0)
    assert_equal(v.z(), 0.0)

