from mo3d.ray.color4 import Color4
from mo3d.math.point import Point

trait Texturable:
    fn value(self, point: Point[...]) -> Color4[...]: ...