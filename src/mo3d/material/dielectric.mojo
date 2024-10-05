from math import sqrt
from random import random_float64

from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord


@value
struct Dielectric[T: DType, dim: Int](CollectionElement):
    var refraction_index: Scalar[T]

    fn scatter(
        self,
        r_in: Ray[T, dim],
        rec: HitRecord[T, dim],
        inout attenuation: Color4[T],
        inout scattered: Ray[T, dim],
    ) -> Bool:
        attenuation = Color4[T](1.0)
        var ri = (
            1.0 / self.refraction_index
        ) if rec.front_face else self.refraction_index

        var unit_direction = r_in.dir.unit()

        var cos_theta = min(-unit_direction.dot(rec.normal), 1.0)
        var sin_theta = sqrt(1.0 - cos_theta * cos_theta)

        var cannot_refract = ri * sin_theta > 1.0
        var direction = Vec[T, dim]()

        if (
            cannot_refract
            or Self.reflectance(cos_theta, ri) > random_float64().cast[T]()
        ):
            direction = Vec[T, dim].reflect(unit_direction, rec.normal)
        else:
            direction = Vec[T, dim].refract(unit_direction, rec.normal, ri)

        scattered = Ray[T, dim](rec.p, direction, r_in.tm)
        return True

    @staticmethod
    fn reflectance(cosine: Scalar[T], refraction_index: Scalar[T]) -> Scalar[T]:
        """
        Use Schlick's approximation for reflectance.
        """
        var r0 = (1 - refraction_index) / (1 + refraction_index)
        r0 = r0 * r0
        return r0 + (1 - r0) * pow((1 - cosine), 5)

    fn emission(self, rec : HitRecord[T,dim]) raises -> Color4[T]:
        return Color4[T](0, 0, 0)

    fn __str__(self) -> String:
        return (
            "Dielectric(refraction_index: " + str(self.refraction_index) + ")"
        )
