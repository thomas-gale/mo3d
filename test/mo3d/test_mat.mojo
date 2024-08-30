from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.math.mat import Mat


fn test_create_empty_vec_size_3_float32() raises:
    var v = Mat[DType.float32, 3]()

    assert_equal(v[0][0], 0.0)
    assert_equal(v[0][1], 0.0)
    assert_equal(v[0][2], 0.0)
    assert_equal(v[1][0], 0.0)
    assert_equal(v[1][1], 0.0)
    assert_equal(v[1][2], 0.0)
    assert_equal(v[2][0], 0.0)
    assert_equal(v[2][1], 0.0)
    assert_equal(v[2][2], 0.0)
