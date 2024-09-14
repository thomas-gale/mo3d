from testing import assert_true, assert_false, assert_equal, assert_almost_equal
 
from mo3d.mlir.my_bool import MyBool, MyTrue, MyFalse

fn test_mlir_my_bool() raises:
	var a: MyBool
	var b = MyBool()
	var c = b
	var e = MyTrue
	var f = MyFalse
	if e: 
		print("Bool conversion!")
	else:
		assert_true(False)
	if ~f:
		print("Invert!")
	else:
		assert_true(False)
