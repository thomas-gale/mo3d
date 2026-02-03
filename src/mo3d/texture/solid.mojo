from mo3d.ray.color4 import Color4

from mo3d.math.point import Point

from python import Python
from python import PythonObject

@fieldwise_init
struct Solid[T: DType, dim: Int](Copyable, Movable):
    var colour : Color4[Self.T]

    fn value(
        self, u: Scalar[Self.T], v: Scalar[Self.T], p: Point[Self.T, Self.dim]
    ) -> Color4[Self.T]:
        return self.colour

    fn __str__(self) -> String:
        return (
            "Soild(colour: "
            + str(self.colour)
            + ")"
        )

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data = Python.dict()
        data["colour"] = self.colour._dump_py_json()
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        return Solid[T,dim](
            Color4[T]._load_py_json(py_obj["colour"]))