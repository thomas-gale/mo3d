from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.math.vec import Vec
from mo3d.math.mat import Mat


fn test_create_empty_mat_size_3_float32() raises:
    var m = Mat[DType.float32, 3]()

    for i in range(3):
        for j in range(3):
            assert_almost_equal(m[i][j], Float32(0.0))


fn test_create_eye_mat_size_3_float32() raises:
    var m = Mat[DType.float32, 3].eye()

    for i in range(3):
        for j in range(3):
            if i == j:
                assert_almost_equal(m[i][j], Float32(1.0))
            else:
                assert_almost_equal(m[i][j], Float32(0.0))


fn test_str_eye_mat_size_3_float32() raises:
    var m = Mat[DType.float32, 3].eye()

    assert_equal(str(m), "1.0, 0.0, 0.0\n0.0, 1.0, 0.0\n0.0, 0.0, 1.0\n")


fn test_set_vec_mat_size_3_float32() raises:
    var v1 = Vec[DType.float32, 3](1.0, 2.0, 3.0)
    var v2 = Vec[DType.float32, 3](11.0, 22.0, 33.0)
    var v3 = Vec[DType.float32, 3](111.0, 222.0, 333.0)

    var m = Mat[DType.float32, 3](v1, v2, v3)

    for i in range(3):
        assert_almost_equal(m[0][i], v1[i])
        assert_almost_equal(m[1][i], v2[i])
        assert_almost_equal(m[2][i], v3[i])

fn test_rotate_mat_size_3_float32() raises:
    var m = Mat[DType.float32, 3].eye()
    var angle = Float32(3.14159 / 2.0)
    var axis = Vec[DType.float32, 3](0.0, 0.0, 1.0)

    var rotated = Mat[DType.float32, 3].rotate_3(m, angle, axis)

    assert_almost_equal(rotated[0][0], Float32(0.0), atol=1e-4)
    assert_almost_equal(rotated[0][1], Float32(1.0), atol=1e-4)
    assert_almost_equal(rotated[0][2], Float32(0.0), atol=1e-4)

    assert_almost_equal(rotated[1][0], Float32(-1.0), atol=1e-4)
    assert_almost_equal(rotated[1][1], Float32(0.0), atol=1e-4)
    assert_almost_equal(rotated[1][2], Float32(0.0), atol=1e-4)

    assert_almost_equal(rotated[2][0], Float32(0.0), atol=1e-4)
    assert_almost_equal(rotated[2][1], Float32(0.0), atol=1e-4)
    assert_almost_equal(rotated[2][2], Float32(1.0), atol=1e-4)
