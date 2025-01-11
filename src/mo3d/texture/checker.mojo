from memory.arc import ArcPointer

from mo3d.ray.color4 import Color4
from mo3d.math.point import Point

from mo3d.texture.texture import Texture

from python import Python
from python import PythonObject

@value
struct Checker[type: DType, dim: Int](CollectionElement):
    var even_texture : ArcPointer[Texture[type, dim]]
    var odd_texture : ArcPointer[Texture[type, dim]]
    var scale : Scalar[type]

    fn value(
        self,
        point : Point[type, dim]
    ) raises -> Color4[type]:
        var sum : Int = 0
        for i in range(dim):
            sum += int(point._data[i] // self.scale)
        if sum % 2 == 0:
            return self.even_texture[].value(point)
        else:
            return self.odd_texture[].value(point)

    fn __str__(self) -> String:
        return (
            "Checker(scale: "
            + str(self.scale)
            + ", even texture: "
            + str(self.even_texture[])
            + ", odd texture: "
            + str(self.odd_texture[])
            + ")"
        )

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data = Python.dict()
        data["even_texture"] = self.even_texture[]._dump_py_json()
        data["odd_texture"] = self.odd_texture[]._dump_py_json()
        data["scale"] = self.scale
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        return Checker[type,dim](
            Texture[type, dim]._load_py_json(py_obj["even_texture"]),
            Texture[type, dim]._load_py_json(py_obj["odd_texture"]),
            float(py_obj["scale"]).cast[type]())