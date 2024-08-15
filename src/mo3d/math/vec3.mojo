from mo3d.numeric import Numeric

# TODO: Initial impl based on https://raytracing.github.io/books/RayTracingInOneWeekend.html#outputanimage

@value
struct Vec3[T: Numeric]():
    var x: T
    var y: T
    var z: T
