from mo3d.math.vec import Vec
from mo3d.math.point import Point

from collections import Optional
from utils import Variant

@value
struct GeomColRecord[T : DType]:
    var pt_a_in_b : Vec[T, 3]  
    var pt_b_in_a : Vec[T, 3]

    fn shift(mut self, delta : Vec[T, 3]):
        self.pt_a_in_b += delta
        self.pt_b_in_a += delta


@value
struct PhysSphere[T : DType]:
    var radius : Scalar[T]

    fn volume(self) -> Scalar[T]:
        return self.radius * self.radius * self.radius

    fn collide_sphere(self, other : PhysSphere[T], rel_p : Point[T, 3]) -> Optional[GeomColRecord[T]]:
        var len = rel_p.length()
        if len > self.radius + other.radius:
            return Optional[GeomColRecord[T]]()
        return GeomColRecord[T](
            (rel_p / len) * self.radius,
            (rel_p / len) * (len - other.radius),
        )



@value
struct PhysGeom[T : DType]:
    alias Variant = Variant[PhysSphere[T]]
    var _geom: Self.Variant

    fn __init__(mut self, geom : Self.Variant) raises:
        if geom.isa[PhysSphere[T]]():
            self._geom = geom
        else:
            raise Error("Geometry c'tor: Unsupported geometry type")

    fn volume(self) -> Scalar[T]:
        if self._geom.isa[PhysSphere[T]]():
            return self._geom[PhysSphere[T]].volume()
        else:
            return 0

fn collision_geometry[T: DType](
    a : PhysGeom[T], 
    b : PhysGeom[T],
    a_p : Point[T, 3],
    b_p : Point[T, 3]
) -> Optional[GeomColRecord[T]]:
    if a._geom.isa[PhysSphere[T]]() and b._geom.isa[PhysSphere[T]]():
        var ba = b_p - a_p
        var col_record = a._geom[PhysSphere[T]].collide_sphere(b._geom[PhysSphere[T]], ba)
        if col_record:
            col_record.value().shift(-ba)
        return col_record
    else:
        return Optional[GeomColRecord[T]]()

    