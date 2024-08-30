from testing import assert_true, assert_false, assert_equal, assert_almost_equal

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

    assert_equal(
        str(m),
        "1.0, 0.0, 0.0\n0.0, 1.0, 0.0\n0.0, 0.0, 1.0\n"
    )
