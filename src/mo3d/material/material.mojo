from utils import Variant

from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.material.dielectric import Dielectric
from mo3d.material.diffuse_light import DiffuseLight

from mo3d.random.rng import Rng

from python import Python
from python import PythonObject

@value
struct Material[T: DType, dim: Int]:
    alias Variant = Variant[
        Lambertian[T, dim], Metal[T, dim], Dielectric[T, dim], DiffuseLight[T, dim]
    ]
    var _mat: Self.Variant

    fn scatter(
        self,
        mut rng : Rng,
        r_in: Ray[T, dim],
        rec: HitRecord[T, dim],
        inout attenuation: Color4[T],
        inout scattered: Ray[T, dim],
    ) raises -> Bool:
        # TODO perform the runtime variant match
        if self._mat.isa[Lambertian[T, dim]]():
            return self._mat[Lambertian[T, dim]].scatter(
                rng, r_in, rec, attenuation, scattered
            )
        elif self._mat.isa[Metal[T, dim]]():
            return self._mat[Metal[T, dim]].scatter(
                rng, r_in, rec, attenuation, scattered
            )
        elif self._mat.isa[Dielectric[T, dim]]():
            return self._mat[Dielectric[T, dim]].scatter(
                rng, r_in, rec, attenuation, scattered
            )
        elif self._mat.isa[DiffuseLight[T, dim]]():
            return self._mat[DiffuseLight[T, dim]].scatter(
                rng, r_in, rec, attenuation, scattered
            )
        raise Error("Material type not supported")

    fn emission(self, rec : HitRecord[T,dim]) raises -> Color4[T]:
        # TODO perform the runtime variant match
        if self._mat.isa[Lambertian[T, dim]]():
            return self._mat[Lambertian[T, dim]].emission(
                rec
            )
        elif self._mat.isa[Metal[T, dim]]():
            return self._mat[Metal[T, dim]].emission(
                rec
            )
        elif self._mat.isa[Dielectric[T, dim]]():
            return self._mat[Dielectric[T, dim]].emission(
                rec
            )
        elif self._mat.isa[DiffuseLight[T, dim]]():
            return self._mat[DiffuseLight[T, dim]].emission(
                rec
            )
        raise Error("Material type not supported")

    fn __str__(self) -> String:
        if self._mat.isa[Lambertian[T, dim]]():
            return str(self._mat[Lambertian[T, dim]])
        elif self._mat.isa[Metal[T, dim]]():
            return str(self._mat[Metal[T, dim]])
        elif self._mat.isa[Dielectric[T, dim]]():
            return str(self._mat[Dielectric[T, dim]])
        else:
            return "Material(Unknown)"

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data : PythonObject
        if self._mat.isa[Lambertian[T, dim]]():
            data = self._mat[Lambertian[T, dim]]._dump_py_json()
            data["type"] = "lambertian"
        elif self._mat.isa[Metal[T, dim]]():
            data = self._mat[Metal[T, dim]]._dump_py_json()
            data["type"] = "metal"
        elif self._mat.isa[Dielectric[T, dim]]():
            data = self._mat[Dielectric[T, dim]]._dump_py_json()
            data["type"] = "dielectric"
        elif self._mat.isa[DiffuseLight[T, dim]]():
            data = self._mat[DiffuseLight[T, dim]]._dump_py_json()
            data["type"] = "diffuse_light"
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
        if type == "lambertian":
            return Self(Lambertian[T, dim]._load_py_json(py_obj))
        elif type == "metal":
            return Self(Metal[T, dim]._load_py_json(py_obj))
        elif type == "dielectric":
            return Self(Dielectric[T, dim]._load_py_json(py_obj))
        elif type == "diffuse_light":
            return Self(DiffuseLight[T, dim]._load_py_json(py_obj))
        else:
            raise Error("Unknown material")
