from utils import Variant

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.geometry.sphere import Sphere
from mo3d.geometry.aabb import AABB
from mo3d.geometry.triangle import Triangle

from mo3d.material.material import Material


@value
struct Geometry[T: DType, dim: Int]:
    alias Variant = Variant[Sphere[T, dim], AABB[T, dim], Triangle[T]]
    var _hittable: Self.Variant

    fn __init__(inout self, hittable: Self.Variant) raises:
        if hittable.isa[Sphere[T, dim]]():
            self._hittable = hittable
        elif hittable.isa[AABB[T, dim]]():
            self._hittable = hittable
        elif hittable.isa[Triangle[T]]():
            self._hittable = hittable
        else:
            raise Error("Geometry c'tor: Unsupported geometry type")

    fn aabb(self) -> AABB[T, dim]:
        if self._hittable.isa[Sphere[T, dim]]():
            return self._hittable[Sphere[T, dim]].aabb()
        elif self._hittable.isa[AABB[T, dim]]():
            return self._hittable[AABB[T, dim]]
        elif self._hittable.isa[Triangle[T]]():
            @parameter
            if dim == 3:
                return rebind[AABB[T, dim]](self._hittable[Triangle[T]].aabb())
            print("Can only use triangles in 3 dimensions tracing")
            return AABB[T, dim]()
        else:
            print("Geometry aabb: Unsupported geometry type")
            return AABB[T, dim]()

    fn hit(
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        inout rec: HitRecord[T, dim]
    ) -> Bool:
        if self._hittable.isa[Sphere[T, dim]]():
            return self._hittable[Sphere[T, dim]].hit(r, ray_t, rec)
        elif self._hittable.isa[AABB[T, dim]]():
            return self._hittable[AABB[T, dim]].hit(r, ray_t, rec)
        elif self._hittable.isa[Triangle[T]]():
            @parameter
            if dim == 3:
                return self._hittable[Triangle[T]].hit(
                    rebind[Ray[T, 3]](r),
                    ray_t,
                    rebind[HitRecord[T, 3]](rec)
                )
            print("Can only use triangles in 3 dimensions tracing")
            return False
        else:
            print("Hittable hit: Unsupported hittable type")
            return False

    fn __str__(self) -> String:
        if self._hittable.isa[Sphere[T, dim]]():
            return str(self._hittable[Sphere[T, dim]])
        elif self._hittable.isa[AABB[T, dim]]():
            return str(self._hittable[AABB[T, dim]])
        elif self._hittable.isa[Triangle[T]]():
            return str(self._hittable[Triangle[T]])
        else:
            return "Geometry(Unknown)"
