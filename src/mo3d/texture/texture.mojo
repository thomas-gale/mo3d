from utils import Variant

from mo3d.ray.color4 import Color4
from mo3d.math.point import Point

from mo3d.texture.solid import Solid
from mo3d.texture.checker import Checker

from python import Python
from python import PythonObject

struct Texture[T: DType, dim: Int](Copyable, Movable):
    comptime Variant = Variant[
        Solid[T, dim], Checker[T, dim]
    ]
    var _tex: Self.Variant

    fn value(
        self,
        point : Point[T, dim]
    ) raises -> Color4[T]:
        # TODO perform the runtime variant match
        if self._tex.isa[Solid[T, dim]]():
            return self._tex[Solid[T, dim]].value(
                point
            )
        elif self._tex.isa[Checker[T, dim]]():
            return self._tex[Checker[T, dim]].value(
                point
            )
        else:
            raise Error("Texture type not supported")

    fn __str__(self) -> String:
        # TODO perform the runtime variant match
        if self._tex.isa[Solid[T, dim]]():
            return str(self._tex[Solid[T, dim]])
        elif self._tex.isa[Checker[T, dim]]():
            return str(self._tex[Checker[T, dim]])
        else:
            return "Texture(Unknown)"

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data : PythonObject
        if self._tex.isa[Solid[T, dim]]():
            data = self._tex[Solid[T, dim]]._dump_py_json()
            data["type"] = "solid"
        elif self._tex.isa[Checker[T, dim]]():
            data = self._tex[Checker[T, dim]]._dump_py_json()
            data["type"] = "checker"
        else:
            data = Python.dict()
            data["type"] = "unknown"
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        var type_s = str(py_obj["type"])
        if type_s == "solid":
            return Self(Solid[T, dim]._load_py_json(py_obj))
        elif type_s == "checker":
            return Self(Checker[T, dim]._load_py_json(py_obj))
        else:
            raise Error("Unknown geometry")