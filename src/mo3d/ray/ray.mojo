from mo3d.math.vec import Vec
from mo3d.math.point import Point


@value
struct Ray[type: DType, dim: Int]:
    var orig: Point[type, dim]
    var dir: Point[type, dim]
    var tm: Scalar[type]

    fn __init__(inout self):
        self.orig = Point[type, dim]()
        self.dir = Vec[type, dim]()
        self.tm = 0.0

    fn __init__(inout self, orig: Point[type, dim], dir: Vec[type, dim], tm: Scalar[type] = 0.0):
        self.orig = orig
        self.dir = dir
        self.tm = tm

    fn at(self, t: Scalar[type]) -> Point[type, dim]:
        return self.orig + self.dir * t

    fn __str__(self) -> String:
        return "Ray(orig=" + str(self.orig) + ", dir=" + str(self.dir) + ")"
