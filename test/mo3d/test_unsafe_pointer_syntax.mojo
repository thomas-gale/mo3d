from memory import UnsafePointer
from testing import assert_equal

fn test_unsafe_pointer_syntax() raises:
    # Test: Pointer to variable using 'to' (Documented way)
    var x = 42
    var ptr = UnsafePointer(to=x)
    print(ptr[])
    assert_equal(ptr[], 42)
    
    # Test: Modification
    ptr[] = 100
    assert_equal(x, 100)
    
    # Test: Null pointer?
    # Based on docs "This pointer is unsafe and nullable"
    # And "UnsafePointer does not have a defaulted origin parameter"
    # Trying to see if we can create one without origin if we don't access it?
    # Or maybe we need to be explicit.
    
    # Try just printing the pointer address or something if possible
    # print(ptr) 

fn main() raises:
    test_unsafe_pointer_syntax()
    print("UnsafePointer syntax test passed")
