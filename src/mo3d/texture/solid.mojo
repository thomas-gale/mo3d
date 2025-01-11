from mo3d.ray.color4 import Color4

from mo3d.math.point import Point

from python import Python
from python import PythonObject

@value
struct Solid[type: DType, dim: Int](CollectionElement):
    var colour : Color4[type]

    fn value(
        self,
        _point : Point[type, dim]
    ) -> Color4[type]:
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