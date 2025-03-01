from mo3d.phys.geometry import PhysGeom

# The data on a component needed to simulate it in phycis
@value
struct PhysData[T : DType]:
    var _geom : PhysGeom[T]
    var _mobile : Bool

