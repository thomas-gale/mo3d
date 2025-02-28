from utils import Variant

@value
struct PhysPlane[T : DType]:

    fn volume(self) -> Scalar[T]:
        return 0

@value
struct PhysSphere[T : DType]:
    var radius : Scalar[T]

    fn volume(self) -> Scalar[T]:
        return self.radius * self.radius * self.radius


@value
struct PhysGeom[T : DType]:
    alias Variant = Variant[PhysPlane[T], PhysSphere[T]]
    var _geom: Self.Variant

    fn __init__(inout self, geom : Self.Variant) raises:
        if geom.isa[PhysSphere[T]]():
            self._geom = geom
        elif geom.isa[PhysPlane[T]]():
            self._geom = geom
        else:
            raise Error("Geometry c'tor: Unsupported geometry type")

    fn volume(self) -> Scalar[T]:
        if self._geom.isa[PhysSphere[T]]():
            return self._geom[PhysSphere[T]].volume()
        elif self._geom.isa[PhysPlane[T]]():
            return self._geom[PhysPlane[T]].volume()
        else:
            return 0

    