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

from python import Python
from python import PythonObject


# Unfortunatly traits currently cant have parameters thus
# we have to have fully generic trait methods and rebind in the
# implementing classes
trait Hittable(CollectionElement):
    """
    The trait to be implemented by all entities that are to be tracable
    (so hit by rays).
    """

    fn aabb[T: DType, dim: Int](self) -> AABB[T, dim]:
        """
        Produce a AABB that bounds the hittable.

        This should be sufficent such that any ray that hits the hittable must enter
        the aabb first.

        It is primarly used to construct BVH for faster rendering.
        """
        ...

    fn hit[
        T: DType, dim: Int
    ](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        mut rec: HitRecord[T, dim],
    ) -> Bool:
        """
        Detect if a given ray (r) hits the geometry in the parameter range (ray_t).

        If so record the conditions of the hit in the hit record (rec):
        The position, paramter value etc.
        """
        ...


@value
struct Geometry[T: DType, dim: Int](Hittable):
    """
    If is not possible to dispatch dynamically on a trait yet in mojo
    for now we make a varient type for the instances of hittable that we
    will want to support and make a manual dispatch chain.
    """

    alias Variant = Variant[Sphere[T, dim], AABB[T, dim], Triangle[T], Mesh[T]]
    var _hittable: Self.Variant

    fn __init__(mut self, hittable: Self.Variant) raises:
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
            return self._hittable[Sphere[T, dim]].aabb[T, dim]()
        elif self._hittable.isa[AABB[T, dim]]():
            return self._hittable[AABB[T, dim]].aabb[T, dim]()
        elif self._hittable.isa[Triangle[T]]():
            return self._hittable[Triangle[T]].aabb[T, dim]()
        elif self._hittable.isa[Mesh[T]]():
            return self._hittable[Mesh[T]].aabb[T, dim]()
        else:
            print("Geometry aabb: Unsupported geometry type")
            return AABB[T, dim]()

    fn hit[
        T: DType, dim: Int
    ](
        self,
        r: Ray[T, dim],
        owned ray_t: Interval[T],
        mut rec: HitRecord[T, dim],
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
            return String(self._hittable[Sphere[T, dim]])
        elif self._hittable.isa[AABB[T, dim]]():
            return String(self._hittable[AABB[T, dim]])
        elif self._hittable.isa[Triangle[T]]():
            return String(self._hittable[Triangle[T]])
        elif self._hittable.isa[Mesh[T]]():
            return String(self._hittable[Mesh[T]])
        else:
            return "Geometry(Unknown)"


    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data : PythonObject
        if self._hittable.isa[Sphere[T, dim]]():
            data = self._hittable[Sphere[T, dim]]._dump_py_json()
            data["type"] = "sphere"
        elif self._hittable.isa[AABB[T, dim]]():
            data = self._hittable[AABB[T, dim]]._dump_py_json()
            data["type"] = "aabb"
        else:
            data = Python.dict()
            data["type"] = "unknown"
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        var type = String(py_obj["type"])
        if type == "sphere":
            return Self(Sphere[T, dim]._load_py_json(py_obj))
        elif type == "aabb":
            return Self(AABB[T, dim]._load_py_json(py_obj))
        else:
            raise Error("Unknown geometry")