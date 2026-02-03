from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.texture.texture import Texture
from mo3d.texture.solid import Solid

from mo3d.random.rng import Rng

from python import Python
from python import PythonObject


@fieldwise_init
struct Lambertian[T: DType, dim: Int](Copyable, Movable):
    var albedo: Texture[Self.T, Self.dim]

    fn scatter(
        self,
        mut rng : Rng,
        r_in: Ray[Self.T, Self.dim],
        rec: HitRecord[Self.T, Self.dim],
        mut attenuation: Color4[Self.T],
        mut scattered: Ray[Self.T, Self.dim],
    ) raises -> Bool:
        var scatter_direction = rec.normal + Vec[Self.T, Self.dim].random_unit_vector(rng)
        # Catch degenerate scatter direction
        if scatter_direction.near_zero():
            scatter_direction = rec.normal
        scattered = Ray[Self.T, Self.dim](rec.p, scatter_direction, r_in.tm)
        attenuation = self.albedo.value(rec.p)
        return True

    fn emission(self, rec : HitRecord[Self.T, Self.dim]) -> Color4[Self.T]:
        return Color4[Self.T](0, 0, 0)

    fn __str__(self) -> String:
        return "Lambertian(albedo: " + str(self.albedo) + ")"

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data = Python.dict()
        data["albedo"] = self.albedo._dump_py_json()
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        return Lambertian[Self.T, Self.dim](
            Texture[Self.T, Self.dim]._load_py_json(py_obj["albedo"]))
