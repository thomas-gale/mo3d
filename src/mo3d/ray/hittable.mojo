# from collections import Variant

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray


# We have to bake in the float_type here, because mojo doesn't support generic traits yet.q
# TODO: Removing for now due to issue ^^
# trait Hittable:
#     fn hit(
#         self,
#         r: Ray[float_type],
#         ray_t: Interval[float_type],
#         inout rec: HitRecord[float_type],
#     ) -> Bool:
#         ...

# alias Hittable = Variant[Sphere]
