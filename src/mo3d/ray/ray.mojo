from mo3d.math.vec import Vec
from mo3d.math.point import Point


@value
struct Ray[type: DType, size: Int]:
    var orig: Point[type, size]
    var dir: Point[type, size]

    fn __init__(inout self):
        self.orig = Point[type, size]()
        self.dir = Vec[type, size]()

    fn __init__(inout self, orig: Point[type, size], dir: Vec[type, size]):
        self.orig = orig
        self.dir = dir

    fn at(self, t: Scalar[type]) -> Point[type, size]:
        return self.orig + self.dir * t
