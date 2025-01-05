from utils import Variant

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.geometry.sphere import Sphere
from mo3d.geometry.aabb import AABB
from mo3d.geometry.triangle import Triangle
from mo3d.geometry.mesh import Mesh

from mo3d.material.material import Material

# Unfortunatly traits currently cant have parameters thus
# we have to have fully generic trait methods and rebind in the 
# implementing classes
trait Hittable(CollectionElement):
    fn aabb[T : DType, dim : Int](self) -> AABB[T, dim]:
        ...
    fn hit[T : DType, dim : Int](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        mut rec: HitRecord[T, dim]) -> Bool:
        ...

@value
struct Geometry[T: DType, dim: Int](Hittable):
    alias Variant = Variant[Sphere[T, dim], AABB[T, dim], Triangle[T], Mesh[T]]
    var _hittable: Self.Variant

    fn __init__(inout self, hittable: Self.Variant) raises:
        if hittable.isa[Sphere[T, dim]]():
            self._hittable = hittable
        elif hittable.isa[AABB[T, dim]]():
            self._hittable = hittable
        elif hittable.isa[Triangle[T]]():
            self._hittable = hittable
        elif hittable.isa[Mesh[T]]():
            self._hittable = hittable
        else:
            raise Error("Geometry c'tor: Unsupported geometry type")

    fn aabb[T: DType, dim: Int](self) -> AABB[T, dim]:
        if self._hittable.isa[Sphere[T, dim]]():
            return self._hittable[Sphere[T, dim]].aabb[T,dim]()
        elif self._hittable.isa[AABB[T, dim]]():
            return self._hittable[AABB[T, dim]].aabb[T,dim]()
        elif self._hittable.isa[Triangle[T]]():
            return self._hittable[Triangle[T]].aabb[T,dim]()
        elif self._hittable.isa[Mesh[T]]():
            return self._hittable[Mesh[T]].aabb[T,dim]()
        else:
            print("Geometry aabb: Unsupported geometry type")
            return AABB[T, dim]()

    fn hit[T: DType, dim: Int](
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
            return self._hittable[Triangle[T]].hit(r, ray_t, rec)
        elif self._hittable.isa[Mesh[T]]():
            return self._hittable[Mesh[T]].hit(r, ray_t, rec)
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
        elif self._hittable.isa[Mesh[T]]():
            return str(self._hittable[Mesh[T]])
        else:
            return "Geometry(Unknown)"
