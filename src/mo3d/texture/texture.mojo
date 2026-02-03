from utils import Variant

from mo3d.ray.color4 import Color4
from mo3d.math.point import Point

from mo3d.texture.solid import Solid
from mo3d.texture.checker import Checker
from mo3d.texture.texturable import Texturable

from python import Python
from python import PythonObject

@fieldwise_init
struct Texture[T: DType, dim: Int](Copyable, ImplicitlyCopyable, Movable, Texturable):
    comptime Variant = Variant[
        Solid[Self.T, Self.dim], Checker[Self.T, Self.dim]
    ]
    var _tex: Self.Variant

    fn value(
        self,
        point : Point[Self.T, Self.dim]
    ) raises -> Color4[Self.T]:
        # TODO perform the runtime variant match
        if self._tex.isa[Solid[Self.T, Self.dim]]():
            return self._tex[Solid[Self.T, Self.dim]].value(
                point
            )
        elif self._tex.isa[Checker[Self.T, Self.dim]]():
            return self._tex[Checker[Self.T, Self.dim]].value(
                point
            )
        else:
            raise Error("Texture type not supported")

    fn __str__(self) -> String:
        # TODO perform the runtime variant match
        if self._tex.isa[Solid[Self.T, Self.dim]]():
            return str(self._tex[Solid[Self.T, Self.dim]])
        elif self._tex.isa[Checker[Self.T, Self.dim]]():
            return str(self._tex[Checker[Self.T, Self.dim]])
        else:
            return "Texture(Unknown)"

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data : PythonObject
        if self._tex.isa[Solid[Self.T, Self.dim]]():
            data = self._tex[Solid[Self.T, Self.dim]]._dump_py_json()
            data["type"] = "solid"
        elif self._tex.isa[Checker[Self.T, Self.dim]]():
            data = self._tex[Checker[Self.T, Self.dim]]._dump_py_json()
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