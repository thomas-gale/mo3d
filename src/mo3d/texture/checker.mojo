from memory.arc import ArcPointer

from mo3d.ray.color4 import Color4
from mo3d.math.point import Point

from mo3d.texture.texture import Texture
from mo3d.texture.solid import Solid

from python import Python
from python import PythonObject

struct Checker[T: DType, dim: Int](Copyable, Movable, Texture[T, dim]):
    var even_texture : ArcPointer[Texture[T, dim]]
    var odd_texture : ArcPointer[Texture[T, dim]]
    var scale : Scalar[T]

    fn value(
        self, u: Scalar[Self.T], v: Scalar[Self.T], p: Point[Self.T, Self.dim]
    ) -> Color4[Self.T]:
        var sum : Int = 0
        for i in range(Self.dim):
            sum += int(p._data[i] // self.scale)
        if sum % 2 == 0:
            return self.even_texture[].value(u, v, p)
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
        return Checker[T,dim](
            Texture[T, dim]._load_py_json(py_obj["even_texture"]),
            Texture[T, dim]._load_py_json(py_obj["odd_texture"]),
            float(py_obj["scale"]).cast[T]())