from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray


@value
struct HitRecord[T: DType, dim: Int]:
    var p: Point[T, dim]
    var normal: Vec[T, dim]
    var t: Scalar[T]
    var front_face: Bool

    fn __init__(inout self):
        self.p = Point[T, dim]()
        self.normal = Vec[T, dim]()
        self.t = Scalar[T]()
        self.front_face = False

    fn set_face_normal(inout self, r: Ray[T, dim], outward_normal: Vec[T, dim]):
        """
        Sets the hit record normal vector.
        NOTE: the parameter `outward_normal` is assumed to have unit length.
        """

        self.front_face = r.dir.dot(outward_normal) < 0
        self.normal = outward_normal if self.front_face else -outward_normal