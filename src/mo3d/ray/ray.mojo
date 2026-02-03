from mo3d.math.vec import Vec
from mo3d.math.mat import RotMat
from mo3d.math.point import Point


struct Ray[T: DType, dim: Int](Copyable, ImplicitlyCopyable, Movable):
    var orig: Point[Self.T, Self.dim]
    var dir: Point[Self.T, Self.dim]
    var tm: Scalar[Self.T]

    fn __init__(out self):
        self.orig = Point[Self.T, Self.dim]()
        self.dir = Vec[Self.T, Self.dim]()
        self.tm = 0.0

    fn __init__(out self, orig: Point[Self.T, Self.dim], dir: Vec[Self.T, Self.dim], tm: Scalar[Self.T] = 0.0):
        self.orig = orig
        self.dir = dir
        self.tm = tm

    fn offset(self, vec : Vec[Self.T, Self.dim]) -> Ray[Self.T, Self.dim]:
        return Ray(self.orig + vec, self.dir, self.tm)

    fn rotate(self, mat : RotMat[Self.T, Self.dim]) -> Ray[Self.T, Self.dim]:
        return Ray(mat * self.orig, mat * self.dir, self.tm)

    fn at(self, t: Scalar[Self.T]) -> Point[Self.T, Self.dim]:
        return self.orig + self.dir * t

    fn __str__(self) -> String:
        return "Ray(orig=" + str(self.orig) + ", dir=" + str(self.dir) + ")"
