from collections import List

from mo3d.precision import float_type
from mo3d.ray.hittable import Hittable, HitRecord
from mo3d.ray.ray4 import Ray4
from mo3d.ray.sphere import Sphere


@value
struct HittableList(Hittable):
    """
    This implementation is horrible, need to try to find a way to store generic lists of concrete hittables using some sort of compile time expansion.
    """

    # Mojo doesn't support polymorphic storage, so we need to have separate of each concrete type.
    var _sphere_list: List[Sphere]
    # e.g.
    # var _other_primitive_list: List[OtherPrimitive]
    # ...

    def __init__(inout self):
        """
        TODO: Variadic comp time constructor based on lists of hittable types we wish to store?.
        """
        self._sphere_list = List[Sphere]()

    def add_sphere(inout self, sphere: Sphere):
        self._sphere_list.append(sphere)

    fn hit(
        self,
        r: Ray4[float_type],
        ray_tmin: Scalar[float_type],
        ray_tmax: Scalar[float_type],
        inout rec: HitRecord[float_type],
    ) -> Bool:
        var hit_anything = False
        var closest_so_far = ray_tmax

        for sphere in self._sphere_list:
            var temp_rec = HitRecord[float_type]()
            if sphere[].hit(r, ray_tmin, closest_so_far, temp_rec):
                hit_anything = True
                closest_so_far = temp_rec.t
                rec = temp_rec

        return hit_anything
