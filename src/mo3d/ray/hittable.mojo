from mo3d.precision import float_type
from mo3d.math.interval import Interval
from mo3d.math.vec4 import Vec4
from mo3d.math.point4 import Point4
from mo3d.ray.ray4 import Ray4


@value
struct HitRecord[T: DType]:
    var p: Point4[T]
    var normal: Vec4[T]
    var t: Scalar[T]
    var front_face: Bool

    fn __init__(inout self):
        self.p = Point4[T]()
        self.normal = Vec4[T]()
        self.t = Scalar[T]()
        self.front_face = False

    fn set_face_normal(inout self, r: Ray4[T], outward_normal: Vec4[T]):
        """
        Sets the hit record normal vector.
        NOTE: the parameter `outward_normal` is assumed to have unit length.
        """

        self.front_face = r.dir.dot(outward_normal) < 0
        self.normal = outward_normal if self.front_face else -outward_normal


# We have to bake in the float_type here, because mojo doesn't support generic traits yet.q
trait Hittable:
    fn hit(
        self,
        r: Ray4[float_type],
        ray_t: Interval[float_type],
        inout rec: HitRecord[float_type],
    ) -> Bool:
        ...
