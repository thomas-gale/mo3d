from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

struct Lambertian[T: DType, dim: Int]:
    var albedo: Color4[T]

    fn __init__(inout self, albedo: Color4[T]):
        self.albedo = albedo

    fn scatter(self, r_in: Ray[T, dim], rec: HitRecord[T, dim], inout attenuation: Color4[T], inout scattered: Ray[T, dim]) -> Bool:
        # Implement Lambertian scattering

        # auto scatter_direction = rec.normal + random_unit_vector();
        # scattered = ray(rec.p, scatter_direction);
        # attenuation = albedo;
        # return true;


        return True