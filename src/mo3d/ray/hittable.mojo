from utils import Variant

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.geometry.sphere import Sphere


@value
struct Hittable[T: DType, dim: Int]:
    alias Variant = Variant[Sphere[T, dim]]
    var _hittable: Self.Variant

    fn hit(
        self,
        r: Ray[T, dim],
        ray_t: Interval[T],
        inout rec: HitRecord[T, dim],
    ) -> Bool:
        # TODO perform the runtime variant match

        return False
