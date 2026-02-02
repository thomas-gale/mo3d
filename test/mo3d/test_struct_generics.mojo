from testing import assert_equal

struct GenericContainer[T: DType, size: Int]:
    var value: Scalar[Self.T] # Fixed: Use Self.T
    
    fn __init__(out self, val: Scalar[Self.T]): 
        self.value = val
        
    fn get_value(self) -> Scalar[Self.T]:
        return self.value

    fn test_access(self):
        print("Size is:", Self.size) 

fn main() raises:
    var c = GenericContainer[DType.int32, 10](42)
    assert_equal(c.get_value(), 42)
    c.test_access()
    print("Struct Generics syntax test passed")
