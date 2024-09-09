from tensor import Tensor

from mo3d.camera.camera import Camera


trait Window:
    @staticmethod
    fn create(name: String, height: Int, width: Int) raises -> Self:
        """
        Create a window with the given name and dimensions.
        """
        ...

    fn process_events(inout self, inout camera: Camera) -> Bool:
        """
        Apply events to the camera.
        Returns True if the window should remain open.
        """
        ...

    fn redraw[
        float_type: DType
    ](self, t: UnsafePointer[Scalar[float_type]], channels: Int) raises -> None:
        """
        Redraw the window with the given texture data buffer (height * width * channels).
        """
        ...
