from utils import Variant

from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.material.lambertian import Lambertian

# We need parametric traits!
# trait Scatterable:
# 	fn scatter(self, r_in: Ray[float_type], rec: HitRecord[float_type], inout attenuation: Color4[float_type], inout scattered: Ray4[float_type]) -> Bool:
# 		...

struct Material[T: DType, dim: Int]:
    alias Variant = Variant[Lambertian[T, dim]]
