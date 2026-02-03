from mo3d.math.vec import Vec
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.random.rng import Rng

from python import Python
from python import PythonObject

@fieldwise_init
struct DiffuseLight[T: DType, dim: Int](Copyable, Movable):
    var emit: Color4[Self.T]

    fn scatter(
        self,
        mut rng : Rng,
        r_in: Ray[Self.T, Self.dim],
        rec: HitRecord[Self.T, Self.dim],
        mut attenuation: Color4[Self.T],
        mut scattered: Ray[Self.T, Self.dim],
    ) -> Bool:
        return False

    fn emission(self, rec : HitRecord[Self.T, Self.dim]) -> Color4[Self.T]:
        return self.emit

    fn __str__(self) -> String:
        return "Diffuse Light(emitting: " + str(self.emit) + ")"

    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var data = Python.dict()
        data["emit"] = self.emit._dump_py_json()
        return data

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        return DiffuseLight[Self.T, Self.dim](
            Color4[Self.T]._load_py_json(py_obj["emit"]))
