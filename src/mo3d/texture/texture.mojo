from utils import Variant

from mo3d.ray.color4 import Color4
from mo3d.math.point import Point

from mo3d.texture.solid import Solid
from mo3d.texture.checker import Checker

from python import Python
from python import PythonObject

@value
struct Texture[type: DType, dim: Int]:
    alias Variant = Variant[
        Solid[type, dim], Checker[type, dim]
    ]
    var _tex: Self.Variant

    fn value(
        self,
        point : Point[type, dim]
    ) raises -> Color4[type]:
        # TODO perform the runtime variant match
        if self._tex.isa[Solid[type, dim]]():
            return self._tex[Solid[type, dim]].value(
                point
            )
        elif self._tex.isa[Checker[type, dim]]():
            return self._tex[Checker[type, dim]].value(
                point
            )
        else:
            raise Error("Texture type not supported")

    fn __str__(self) -> String:
        # TODO perform the runtime variant match
        if self._tex.isa[Solid[type, dim]]():
            return str(self._tex[Solid[type, dim]])
        elif self._tex.isa[Checker[type, dim]]():
            return str(self._tex[Checker[type, dim]])
        else:
            return "Texture(Unknown)"

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data : PythonObject
        if self._tex.isa[Solid[type, dim]]():
            data = self._tex[Solid[type, dim]]._dump_py_json()
            data["type"] = "solid"
        elif self._tex.isa[Checker[type, dim]]():
            data = self._tex[Checker[type, dim]]._dump_py_json()
            data["type"] = "checker"
        else:
            data = Python.dict()
            data["type"] = "unknown"
        return data