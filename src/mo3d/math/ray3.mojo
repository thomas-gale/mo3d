from mo3d.math.vec3 import Vec3
from mo3d.math.point3 import Point3


@value
struct Ray3[type: DType]:
    var orig: Point3[type]
    var dir: Point3[type]

    fn __init__(inout self):
        self.orig = Point3[type]()
        self.dir = Vec3[type]()

    fn __init__(inout self, orig: Point3[type], dir: Vec3[type]):
        self.orig = orig
        self.dir = dir

    fn at(self, t: Scalar[type]) -> Point3[type]:
        return self.orig + self.dir * t
