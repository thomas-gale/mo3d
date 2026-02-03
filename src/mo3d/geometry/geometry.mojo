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


trait Hittable(Copyable, Movable):
    """
    The trait to be implemented by all entities that are to be tracable
    (so hit by rays).
    """

    # Work around due to traits not supported generic parameterisation
    comptime T: DType
    comptime dim: Int

    fn aabb(self) -> AABB[Self.T, Self.dim]:
        """
        Produce a AABB that bounds the hittable.

        This should be sufficent such that any ray that hits the hittable must enter
        the aabb first.

        It is primarly used to construct BVH for faster rendering.
        """
        ...

    fn hit(
        self,
        r: Ray[Self.T, Self.dim],
        var ray_t: Interval[Self.T],
        mut rec: HitRecord[Self.T, Self.dim],
    ) -> Bool:
        """
        Detect if a given ray (r) hits the geometry in the parameter range (ray_t).

        If so record the conditions of the hit in the hit record (rec):
        The position, paramter value etc.
        """
        ...


struct Geometry[_T: DType, _dim: Int](Copyable, ImplicitlyCopyable, Movable, Hittable):
    """
    If is not possible to dispatch dynamically on a trait yet in mojo
    for now we make a varient type for the instances of hittable that we
    will want to support and make a manual dispatch chain.
    """

    comptime T = Self._T
    comptime dim = Self._dim  

    comptime Variant = Variant[Sphere[Self.T, Self.dim], AABB[Self.T, Self.dim], Triangle[Self.T], Mesh[Self.T]]
    var _hittable: Self.Variant

    fn __init__(out self, hittable: Self.Variant) raises:
        if hittable.isa[Sphere[Self.T, Self.dim]]():
            self._hittable = hittable
        elif hittable.isa[AABB[Self.T, Self.dim]]():
            self._hittable = hittable
        elif hittable.isa[Triangle[Self.T]]():
            self._hittable = hittable
        elif hittable.isa[Mesh[Self.T]]():
            self._hittable = hittable
        else:
            raise Error("Geometry c'tor: Unsupported geometry type")

    fn aabb(self) -> AABB[Self.T, Self.dim]:
        if self._hittable.isa[Sphere[Self.T, Self.dim]]():
            return self._hittable[Sphere[Self.T, Self.dim]].aabb[Self.T, Self.dim]()
        elif self._hittable.isa[AABB[Self.T, Self.dim]]():
            return self._hittable[AABB[Self.T, Self.dim]].aabb[Self.T, Self.dim]()
        elif self._hittable.isa[Triangle[Self.T]]():
            return self._hittable[Triangle[Self.T]].aabb[Self.T, Self.dim]()
        elif self._hittable.isa[Mesh[Self.T]]():
            return self._hittable[Mesh[Self.T]].aabb[Self.T, Self.dim]()
        else:
            print("Geometry aabb: Unsupported geometry type")
            return AABB[T, dim]()

    fn hit(
        self,
        r: Ray[Self.T, Self.dim],
        var ray_t: Interval[Self.T],
        mut rec: HitRecord[Self.T, Self.dim],
    ) -> Bool:
        if self._hittable.isa[Sphere[Self.T, Self.dim]]():
            return self._hittable[Sphere[Self.T, Self.dim]].hit(r, ray_t, rec)
        elif self._hittable.isa[AABB[Self.T, Self.dim]]():
            return self._hittable[AABB[Self.T, Self.dim]].hit(r, ray_t, rec)
        elif self._hittable.isa[Triangle[Self.T]]():
            return self._hittable[Triangle[Self.T]].hit(r, ray_t, rec)
        elif self._hittable.isa[Mesh[Self.T]]():
            return self._hittable[Mesh[Self.T]].hit(r, ray_t, rec)
        else:
            print("Hittable hit: Unsupported hittable type")
            return False

    fn __str__(self) -> String:
        if self._hittable.isa[Sphere[Self.T, Self.dim]]():
            return str(self._hittable[Sphere[Self.T, Self.dim]])
        elif self._hittable.isa[AABB[Self.T, Self.dim]]():
            return str(self._hittable[AABB[Self.T, Self.dim]])
        elif self._hittable.isa[Triangle[Self.T]]():
            return str(self._hittable[Triangle[Self.T]])
        elif self._hittable.isa[Mesh[Self.T]]():
            return str(self._hittable[Mesh[Self.T]])
        else:
            return "Geometry(Unknown)"


    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data : PythonObject
        if self._hittable.isa[Sphere[Self.T, Self.dim]]():
            data = self._hittable[Sphere[Self.T, Self.dim]]._dump_py_json()
            data["type"] = "sphere"
        elif self._hittable.isa[AABB[Self.T, Self.dim]]():
            data = self._hittable[AABB[Self.T, Self.dim]]._dump_py_json()
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
        var type = str(py_obj["type"])
        if type == "sphere":
            return Self(Sphere[Self.T, Self.dim]._load_py_json(py_obj))
        elif type == "aabb":
            return Self(AABB[Self.T, Self.dim]._load_py_json(py_obj))
        else:
            raise Error("Unknown geometry")