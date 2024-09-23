from utils import Variant

from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.material.dielectric import Dielectric


@value
struct Material[T: DType, dim: Int]:
    alias Variant = Variant[
        Lambertian[T, dim], Metal[T, dim], Dielectric[T, dim]
    ]
    var _mat: Self.Variant

    fn scatter(
        self,
        r_in: Ray[T, dim],
        rec: HitRecord[T, dim],
        inout attenuation: Color4[T],
        inout scattered: Ray[T, dim],
    ) raises -> Bool:
        # TODO perform the runtime variant match
        if self._mat.isa[Lambertian[T, dim]]():
            return self._mat[Lambertian[T, dim]].scatter(
                r_in, rec, attenuation, scattered
            )
        elif self._mat.isa[Metal[T, dim]]():
            return self._mat[Metal[T, dim]].scatter(
                r_in, rec, attenuation, scattered
            )

        elif self._mat.isa[Dielectric[T, dim]]():
            return self._mat[Dielectric[T, dim]].scatter(
                r_in, rec, attenuation, scattered
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
