from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.color4 import Color4

from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian

from mo3d.texture.texture import Texture
from mo3d.texture.texture import Solid

struct HitRecord[T: DType, dim: Int](Copyable, Movable):
    var p: Point[Self.T, Self.dim]
    var normal: Vec[Self.T, Self.dim]
    var mat: Material[Self.T, Self.dim]
    var t: Scalar[Self.T]
    var front_face: Bool
    var hits: Int

    fn __init__(out self):
        self.p = Point[Self.T, Self.dim]()
        self.normal = Vec[Self.T, Self.dim]()
        self.mat = Material[Self.T, Self.dim](Lambertian[Self.T, Self.dim](
            Texture[Self.T, Self.dim](Solid[Self.T, Self.dim](Color4[Self.T](0.0)))
        ))
        self.t = Scalar[Self.Self.T]()
        self.front_face = False
        self.hits = 0

    fn set_face_normal(mut self, r: Ray[Self.T, Self.dim], outward_normal: Vec[Self.T, Self.dim]):
        """
        Sets the hit record normal vector.
        NOTE: the parameter `outward_normal` is assumed to have unit length.
        """

        self.front_face = r.dir.dot(outward_normal) < 0
        self.normal = outward_normal if self.front_face else -outward_normal

    fn __str__(self) -> String:
        return (
            "HitRecord(p: "
            + str(self.p)
            + ", normal: "
            + str(self.normal)
            + ", t: "
            + str(self.t)
            + ", front_face: "
            + str(self.front_face)
            + ")"
        )
