from mo3d.math.vec4 import Vec4
from mo3d.math.point4 import Point4


@value
struct Ray[type: DType]:
    var orig: Point4[type]
    var dir: Point4[type]

    def __init__(inout self):
        self.orig = Point4[type]()
        self.dir = Vec4[type]()
