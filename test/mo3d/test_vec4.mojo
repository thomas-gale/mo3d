from testing import assert_true, assert_equal, assert_almost_equal

from mo3d.math import Vec4


fn test_create_empty_vec4_float32() raises:
    var v = Vec4[DType.float32]()

    assert_equal(v.x(), 0.0, msg="Vec4 x component not working")
    assert_equal(v.y(), 0.0, msg="Vec4 y component not working")
    assert_equal(v.z(), 0.0, msg="Vec4 z component not working")
    assert_equal(v.w(), 0.0, msg="Vec4 w component not working")

fn test_create_vec4_float32() raises:
    var v = Vec4(SIMD[DType.float32, 4](42.0, 43.0, 44.0, 1.0))

    assert_equal(v.x(), 42.0, msg="Vec4 x component not working")
    assert_equal(v.y(), 43.0, msg="Vec4 y component not working")
    assert_equal(v.z(), 44.0, msg="Vec4 z component not working")
    assert_equal(v.w(), 1.0, msg="Vec4 w component not working")
