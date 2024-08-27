from tensor import Tensor

trait Window:
    @staticmethod
    fn create(name: String, height: Int, width: Int) raises -> Self:
        ...

    fn should_close(self) -> Bool:
        ...

    # ](self, t: Tensor[float_type], channels: Int) raises -> None:
    
    fn redraw[
        float_type: DType
    ](self, t: UnsafePointer[Scalar[float_type]], channels: Int) raises -> None:
        ...
