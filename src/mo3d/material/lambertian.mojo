from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.texture.texture import Texture
from mo3d.texture.solid import Solid


@value
struct Lambertian[T: DType, dim: Int](CollectionElement):
    var albedo: Texture[T, dim]

    fn __init__(inout self, albedo: Color4[T]):
        self.albedo = Solid[T, dim](albedo)

    fn scatter(
        self,
        r_in: Ray[T, dim],
        rec: HitRecord[T, dim],
        inout attenuation: Color4[T],
        inout scattered: Ray[T, dim],
    ) raises -> Bool:
        var scatter_direction = rec.normal + Vec[T, dim].random_unit_vector()
        # Catch degenerate scatter direction
        if scatter_direction.near_zero():
            scatter_direction = rec.normal
        scattered = Ray[T, dim](rec.p, scatter_direction, r_in.tm)
        attenuation = self.albedo.value(rec.p)
        return True

    fn __str__(self) -> String:
        return "Lambertian(albedo: " + str(self.albedo) + ")"
