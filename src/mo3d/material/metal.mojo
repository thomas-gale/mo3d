from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.random.rng import Rng

from python import Python
from python import PythonObject

@fieldwise_init
struct Metal[T: DType, dim: Int](Copyable, Movable):
    var albedo: Color4[Self.T]
    var fuzz: Scalar[Self.T]

    fn scatter(
        self,
        mut rng : Rng,
        r_in: Ray[Self.T, Self.dim],
        rec: HitRecord[Self.T, Self.dim],
        mut attenuation: Color4[Self.T],
        mut scattered: Ray[Self.T, Self.dim],
    ) -> Bool:
        var reflected = Vec[Self.T, Self.dim].reflect(r_in.dir, rec.normal)
        reflected = reflected.unit() + (
            self.fuzz * Vec[Self.T, Self.dim].random_unit_vector(rng)
        )
        scattered = Ray[Self.T, Self.dim](rec.p, reflected, r_in.tm)
        attenuation = self.albedo
        return scattered.dir.dot(rec.normal) > 0.0

    fn emission(self, rec : HitRecord[Self.T, Self.dim]) -> Color4[Self.T]:
        return Color4[Self.T](0, 0, 0)

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

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        return Metal[Self.T, dim](
            Color4[Self.T]._load_py_json(py_obj["albedo"]),
            float(py_obj["fuzz"]).cast[Self.T]())
