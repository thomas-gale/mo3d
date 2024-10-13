from mo3d.ray.color4 import Color4

from mo3d.math.point import Point

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
