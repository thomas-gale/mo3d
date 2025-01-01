from memory.arc import ArcPointer

from mo3d.ray.color4 import Color4
from mo3d.math.point import Point

from mo3d.texture.texture import Texture

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