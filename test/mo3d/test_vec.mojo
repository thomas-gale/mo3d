from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.math.vec import Vec


fn test_create_empty_vec_size_3_float32() raises:
    var v = Vec[DType.float32, 3]()

    assert_equal(v[0], 0.0)
    assert_equal(v[1], 0.0)
    assert_equal(v[2], 0.0)


fn test_create_vec_size_3_float32() raises:
    var v = Vec[DType.float32, 3](42.0, 43.0, 44.0)

    assert_equal(v[0], 42.0)
    assert_equal(v[1], 43.0)
    assert_equal(v[2], 44.0)

fn test_mul() raises:
    var v = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    var scalar: Float32 = 2.0
    var result = v * scalar

    assert_equal(result[0], 2.0)
    assert_equal(result[1], 4.0)
    assert_equal(result[2], 6.0)

fn test_imul() raises:
    var v = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    var scalar: Float32 = 2.0
    v *= scalar

    assert_equal(v[0], 2.0)
    assert_equal(v[1], 4.0)
    assert_equal(v[2], 6.0)

fn test_div() raises:
    var v = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    var scalar: Float32 = 2.0
    var result = v / scalar

    assert_equal(result[0], 0.5)
    assert_equal(result[1], 1.0)
    assert_equal(result[2], 1.5)

fn test_idiv() raises:
    var v = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    var scalar: Float32 = 2.0
    v /= scalar

    assert_equal(v[0], 0.5)
    assert_equal(v[1], 1.0)
    assert_equal(v[2], 1.5)

fn test_length_squared() raises:
    var v = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    assert_equal(v.length_squared(), 14.0)

fn test_length() raises:
    var v = Vec[DType.float32, 3](3.0, 4.0, 0.0)
    assert_equal(v.length(), 5)


fn test_dot() raises:
    var v1 = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    var v2 = Vec[DType.float32, 3](5.0, 6.0, 7.0)
    assert_equal(v1.dot(v2), 38.0)


fn test_cross() raises:
    var v1 = Vec[DType.float32, 3](1.0, 0.0, 0.0)
    var v2 = Vec[DType.float32, 3](0.0, 1.0, 0.0)
    var v3 = Vec[DType.float32, 3](0.0, 0.0, 1.0)
    assert_equal(v1.cross(v2), v3)


fn test_unit() raises:
    var v = Vec[DType.float32, 3](3.0, 4.0, 0.0, 0.0)
    assert_almost_equal(v.unit().length(), 1.0)


fn test_str() raises:
    var v = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    assert_equal(str(v), "1.0, 2.0, 3.0")


fn test_comparison() raises:
    var v1 = Vec[DType.float32, 3](1.0, 2.0, 2.0)
    var v2 = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    var v3 = Vec[DType.float32, 3](1.0, 4.0, 7.0)
    var v4 = Vec[DType.float32, 3](2.0, 1.0, 7.0)

    assert_true(v1 < v2)
    assert_true(v3 < v4)
    assert_true(v1 <= v2)
    assert_true(v2 <= v2)
    assert_true(v2 == v2)
    assert_true(v1 != v2)
    assert_true(v3 > v2)
    assert_true(v4 > v3)
    assert_true(v4 >= v3)
