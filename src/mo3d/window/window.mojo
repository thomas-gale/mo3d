from tensor import Tensor

from mo3d.camera.camera import Camera


trait Window:
    @staticmethod
    fn create(name: String, height: Int, width: Int) raises -> Self:
        ...

    fn process_events(inout self, inout camera: Camera) -> Bool:
        """
        TODO: Create a nice event struct to return/modify camera directly?.
        """
        ...

    fn redraw[
        float_type: DType
    ](self, t: UnsafePointer[Scalar[float_type]], channels: Int) raises -> None:
        ...
