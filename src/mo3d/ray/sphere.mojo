from math import sqrt

from mo3d.math.point4 import Point4
from mo3d.ray.ray4 import Ray4


fn hit_sphere[
    float_type: DType
](
    center: Point4[float_type], radius: Scalar[float_type], r: Ray4[float_type]
) -> Scalar[float_type]:
    var oc = center - r.orig
    var a = r.dir.length_squared()
    var h = r.dir.dot(oc)
    var c = oc.length_squared() - radius * radius
    var discriminant = h * h - a * c

    if discriminant < 0:
        return -1.0
    else:
        return (h - sqrt(discriminant)) / a
