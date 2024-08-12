from mo3d.numeric import Numeric


@value
struct Vec3[T: Numeric]():
    var x: T
    var y: T
    var z: T
