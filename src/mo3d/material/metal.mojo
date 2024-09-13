from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord


@value
struct Metal[T: DType, dim: Int](CollectionElement):
    var albedo: Color4[T]
    var fuzz: Scalar[T]

    fn scatter(
        self,
        r_in: Ray[T, dim],
        rec: HitRecord[T, dim],
        inout attenuation: Color4[T],
        inout scattered: Ray[T, dim],
    ) -> Bool:
        var reflected = Vec[T, dim].reflect(r_in.dir, rec.normal)
        reflected = reflected.unit() + (
            self.fuzz * Vec[T, dim].random_unit_vector()
        )
        scattered = Ray[T, dim](rec.p, reflected, r_in.tm)
        attenuation = self.albedo
        return scattered.dir.dot(rec.normal) > 0.0
