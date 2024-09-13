from collections import List

from mo3d.math.interval import Interval
from mo3d.ray.hit_record import HitRecord
from mo3d.ray.ray import Ray

from mo3d.geometry.sphere import Sphere


@value
struct HittableList[T: DType, dim: Int]:
    """
    This implementation is horrible, need to try to find a way to store generic lists of concrete hittables using some sort of compile time expansion.
    """

    # Mojo doesn't support polymorphic storage, so we need to have separate of each concrete type.
    # I think this can be a list of Variants[Various Types....]

    var _sphere_list: List[Sphere[T, dim]]
    # e.g.
    # var _other_primitive_list: List[OtherPrimitive]
    # ...

    def __init__(inout self):
        """
        TODO: Variadic comp time constructor based on lists of hittable types we wish to store?.
        """
        self._sphere_list = List[Sphere[T, dim]]()

    def add_sphere(inout self, sphere: Sphere[T, dim]):
        self._sphere_list.append(sphere)

    fn hit(
        self,
        r: Ray[T, dim],
        ray_t: Interval[T],
        inout rec: HitRecord[T, dim],
    ) -> Bool:
        var temp_rec = HitRecord[T, dim]()
        var hit_anything = False
        var closest_so_far = ray_t.max

        for sphere in self._sphere_list:
            if sphere[].hit(r, Interval(ray_t.min, closest_so_far), temp_rec):
                hit_anything = True
                closest_so_far = temp_rec.t
                rec = temp_rec

        return hit_anything
