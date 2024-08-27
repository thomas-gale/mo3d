from mo3d.precision import float_type
from mo3d.ray.color4 import Color4
from mo3d.ray.ray4 import Ray4
from mo3d.ray.hittable import HitRecord

trait Scatterable:
	fn scatter(self, r_in: Ray4[float_type], rec: HitRecord[float_type], inout attenuation: Color4[float_type], inout scattered: Ray4[float_type]) -> Bool:
		...

struct Material(Scatterable):
	fn scatter(self, r_in: Ray4[float_type], rec: HitRecord[float_type], inout attenuation: Color4[float_type], inout scattered: Ray4[float_type]) -> Bool:
		return True
