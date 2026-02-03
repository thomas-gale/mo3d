from math import sqrt

from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.random.rng import Rng

from python import Python
from python import PythonObject

@fieldwise_init
struct Dielectric[T: DType, dim: Int](Copyable, Movable):
    var refraction_index: Scalar[Self.T]

    fn scatter(
        self,
        mut rng : Rng,
        r_in: Ray[Self.T, Self.dim],
        rec: HitRecord[Self.T, Self.dim],
        mut attenuation: Color4[Self.T],
        mut scattered: Ray[Self.T, Self.dim],
    ) -> Bool:
        attenuation = Color4[Self.T](1.0)
        var ri = (
            1.0 / self.refraction_index
        ) if rec.front_face else self.refraction_index

        var unit_direction = r_in.dir.unit()

        var cos_theta = min(-unit_direction.dot(rec.normal), 1.0)
        var sin_theta = sqrt(1.0 - cos_theta * cos_theta)

        var cannot_refract = ri * sin_theta > 1.0
        var direction = Vec[Self.T, Self.dim]()

        if (
            cannot_refract
            or Self.reflectance(cos_theta, ri) > rng.float64().cast[Self.T]()
        ):
            direction = Vec[Self.T, Self.dim].reflect(unit_direction, rec.normal)
        else:
            direction = Vec[Self.T, Self.dim].refract(unit_direction, rec.normal, ri)

        scattered = Ray[Self.T, Self.dim](rec.p, direction, r_in.tm)
        return True

    @staticmethod
    fn reflectance(cosine: Scalar[Self.T], refraction_index: Scalar[Self.T]) -> Scalar[Self.T]:
        """
        Use Schlick's approximation for reflectance.
        """
        var r0 = (1 - refraction_index) / (1 + refraction_index)
        r0 = r0 * r0
        return r0 + (1 - r0) * pow((1 - cosine), 5)

    fn emission(self, rec : HitRecord[Self.T, Self.dim]) raises -> Color4[Self.T]:
        return Color4[Self.T](0, 0, 0)

    fn __str__(self) -> String:
        return (
            "Dielectric(refraction_index: " + str(self.refraction_index) + ")"
        )

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data = Python.dict()
        data["refration_index"] = self.refraction_index
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        return Dielectric[Self.T, Self.dim](
            float(py_obj["refration_index"]).cast[Self.T]())
