from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.random.rng import Rng

from python import Python
from python import PythonObject

@value
struct Metal[T: DType, dim: Int](CollectionElement):
    var albedo: Color4[T]
    var fuzz: Scalar[T]

    fn scatter(
        self,
        mut rng : Rng,
        r_in: Ray[T, dim],
        rec: HitRecord[T, dim],
        inout attenuation: Color4[T],
        inout scattered: Ray[T, dim],
    ) -> Bool:
        var reflected = Vec[T, dim].reflect(r_in.dir, rec.normal)
        reflected = reflected.unit() + (
            self.fuzz * Vec[T, dim].random_unit_vector(rng)
        )
        scattered = Ray[T, dim](rec.p, reflected, r_in.tm)
        attenuation = self.albedo
        return scattered.dir.dot(rec.normal) > 0.0

    fn emission(self, rec : HitRecord[T,dim]) -> Color4[T]:
        return Color4[T](0, 0, 0)

    fn __str__(self) -> String:
        return (
            "Metal(albedo: "
            + str(self.albedo)
            + ", fuzz: "
            + str(self.fuzz)
            + ")"
        )

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data = Python.dict()
        data["albedo"] = self.albedo._dump_py_json()
        data["fuzz"] = self.fuzz
        return data
