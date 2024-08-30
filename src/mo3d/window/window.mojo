from tensor import Tensor


trait Window:
    @staticmethod
    fn create(name: String, height: Int, width: Int) raises -> Self:
        ...

    fn process_events(inout self) -> Bool:
        """
        TODO: Create a nice event struct to return.
        """
        ...

    fn redraw[
        float_type: DType
    ](self, t: UnsafePointer[Scalar[float_type]], channels: Int) raises -> None:
        ...
