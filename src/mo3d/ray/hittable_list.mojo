from collections import List

from mo3d.precision import float_type
from mo3d.ray.hittable import Hittable, HitRecord
from mo3d.ray.ray4 import Ray4


@value
struct HittableList(Hittable):
    var _list: List[UnsafePointer[Hittable]]

    fn hit(
        self,
        r: Ray4[float_type],
        ray_tmin: Scalar[float_type],
        ray_tmax: Scalar[float_type],
        inout rec: HitRecord[float_type],
    ) -> Bool:
        return False
