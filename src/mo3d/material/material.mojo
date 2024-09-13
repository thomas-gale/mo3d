from utils import Variant

from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.material.lambertian import Lambertian

@value
struct Material[T: DType, dim: Int]:
    alias Variant = Variant[Lambertian[T, dim]]
    var _mat: Self.Variant

    fn scatter(self, r_in: Ray[T, dim], rec: HitRecord[T, dim], inout attenuation: Color4[T], inout scattered: Ray[T, dim]) -> Bool:
        # TODO perform the variant match

        return True
