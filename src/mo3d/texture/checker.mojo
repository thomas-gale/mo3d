from math import floor

from mo3d.ray.color4 import Color4
from mo3d.math.point import Point

from mo3d.texture.texture import Texture

@value
struct Checker[type: DType, dim: Int](CollectionElement):
    var inverse_scale : Scalar[type]
    var even_texture : Texture[type, dim]
    var odd_texture : Texture[type, dim]

    fn __init__(
        inout self, 
        scale : Scalar[type], 
        even_texture : Texture[type, dim], 
        odd_texture : Texture[type, dim]
    ):
        self.inverse_scale = 1.0 / scale
        self.odd_texture = odd_texture
        self.even_texture = even_texture

    fn value(
        self,
        point : Point[type, dim]
    ) raises -> Color4[type]:
        var sum: Int = 0
        for i in range(dim):
            sum += int(floor(self.inverse_scale * point[i]))
        if sum % 2 == 0:
            return self.even_texture.value(point)
        else:
            return self.odd_texture.value(point)

    fn __str__(self) -> String:
        return (
            "Texture(even: "
            + str(self.even_texture)
            ", odd: "
            + str(self.odd_texture)
            ", size: "
            + str(1.0 / self.inverse_scale)
            + ")"
        )
