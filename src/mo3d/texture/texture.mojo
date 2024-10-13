from utils import Variant

from mo3d.ray.color4 import Color4

from mo3d.math.point import Point

from mo3d.texture.solid import Solid
from mo3d.texture.checker import Checker

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
        raise Error("Texture type not supported")

    fn __str__(self) -> String:
        if self._tex.isa[Solid[type, dim]]():
            return str(self._tex[Solid[type, dim]])
        elif self._tex.isa[Checker[type, dim]]():
            return str(self._tex[Checker[type, dim]])
        else:
            return "Texture(Unknown)"
