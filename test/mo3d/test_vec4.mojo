from testing import assert_true, assert_equal, assert_almost_equal

from mo3d.math.vec4 import Vec4


fn test_create_empty_vec4_float32() raises:
    var v = Vec4[DType.float32]()

    assert_equal(v.x(), 0.0)
    assert_equal(v.y(), 0.0)
    assert_equal(v.z(), 0.0)
    assert_equal(v.w(), 0.0)


fn test_create_vec4_float32() raises:
    var v = Vec4(SIMD[DType.float32, 4](42.0, 43.0, 44.0, 1.0))

    assert_equal(v.x(), 42.0)
    assert_equal(v.y(), 43.0)
    assert_equal(v.z(), 44.0)
    assert_equal(v.w(), 1.0)


fn test_length_squared() raises:
    var v = Vec4(SIMD[DType.float32, 4](1.0, 2.0, 3.0, 4.0))
    assert_equal(v.length_squared(), 30.0)


fn test_length() raises:
    var v = Vec4(SIMD[DType.float32, 4](3.0, 4.0, 0.0, 0.0))
    assert_equal(v.length(), 5)

fn test_dot() raises:
    var v1 = Vec4(SIMD[DType.float32, 4](1.0, 2.0, 3.0, 4.0))
    var v2 = Vec4(SIMD[DType.float32, 4](5.0, 6.0, 7.0, 8.0))
    assert_equal(v1.dot(v2), 70.0)

fn test_cross() raises:
    var v1 = Vec4(SIMD[DType.float32, 4](1.0, 0.0, 0.0, 0.0))
    var v2 = Vec4(SIMD[DType.float32, 4](0.0, 1.0, 0.0, 0.0))
    var v3 = Vec4(SIMD[DType.float32, 4](0.0, 0.0, 1.0, 0.0))
    assert_equal(v1.cross(v2), v3)

fn test_unit() raises:
    var v = Vec4(SIMD[DType.float32, 4](3.0, 4.0, 0.0, 0.0))
    assert_almost_equal(v.unit().length(), 1.0)

fn test_str() raises:
    var v = Vec4(SIMD[DType.float32, 4](1.0, 2.0, 3.0, 4.0))
    assert_equal(str(v), "1.0, 2.0, 3.0, 4.0")

fn test_repr() raises:
    var v = Vec4(SIMD[DType.float32, 4](1.0, 2.0, 3.0, 4.0))
    assert_equal(
        repr(v),
        "Vec4(SIMD[DType.float32, 4](1.0, 2.0, 3.0, 4.0))"
    )
