from mo3d.math.vec4 import Vec4
from mo3d.math.point4 import Point4
from mo3d.ray.ray4 import Ray4


struct HitRecord[T: DType]:
    var p: Point4[T]
    var normal: Vec4[T]
    var t: Scalar[T]


trait Hittable:
    fn hit[
        T: DType
    ](
        self,
        r: Ray4[T],
        ray_tmin: Scalar[T],
        ray_tmax: Scalar[T],
        rec: HitRecord[T],
    ) -> Bool:
        ...
