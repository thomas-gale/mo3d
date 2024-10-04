from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord


@value
struct DiffuseLight[T: DType, dim: Int](CollectionElement):
    var emit: Color4[T]

    fn scatter(
        self,
        r_in: Ray[T, dim],
        rec: HitRecord[T, dim],
        inout attenuation: Color4[T],
        inout scattered: Ray[T, dim],
    ) -> Bool:
        return False

    fn emission(self, rec : HitRecord[T,dim]) -> Color4[T]:
        return self.emit

    fn __str__(self) -> String:
        return "Diffuse Light(emitting: " + str(self.emit) + ")"
