from mo3d.math.vec4 import Vec4
from mo3d.math.point4 import Point4


@value
struct Ray4[type: DType]:
    var orig: Point4[type]
    var dir: Point4[type]

    fn __init__(inout self):
        self.orig = Point4[type]()
        self.dir = Vec4[type]()

    fn __init__(inout self, orig: Point4[type], dir: Vec4[type]):
        self.orig = orig
        self.dir = dir

    fn at(self, t: Scalar[type]) -> Point4[type]:
        return self.orig + self.dir * t
