from testing import assert_true, assert_equal, assert_almost_equal

from mo3d.numeric import NumericFloat32

fn test_create_numeric_float32() raises:
    var x = NumericFloat32(42.0)
    var y = NumericFloat32(-32.0)

    assert_true(y < x, msg="NumericFloat32 less than operator not working")
    assert_true(x > y, msg="NumericFloat32 greater than operator not working")
    assert_true(x != y, msg="NumericFloat32 ne operator not working")
    assert_true(x == x, msg="NumericFloat32 eq operator not working")