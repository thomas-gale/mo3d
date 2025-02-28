# Initial outline in https://winter.dev/articles/physics-engine

from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.math.mat import RotMat, Mat

from mo3d.phys.geometry import PhysGeom

from collections import Optional
from memory import UnsafePointer




@value 
struct CollisionRecord[T : DType]:
    alias FloatType = T # Needed to get around some isues with trait param
    var a_ptr : UnsafePointer[Entity[T]]
    var b_ptr : UnsafePointer[Entity[T]]
    var pt_a_in_b : Vec[T, 3]  
    var pt_b_in_a : Vec[T, 3]

@value
struct Entity[T: DType]:
    var _geom : PhysGeom[T]
    var _pos : Point[T, 3]
    var _vel : Vec[T, 3]
    var _force : Vec[T, 3]
    var mobile : Bool

    fn apply_force(inout self, force : Vec[T, 3]):
        self._force += force

    fn move_by(inout self, dir : Vec[T, 3]):
        self._pos += dir

    fn move(inout self, step : Scalar[T]):
        if not self.mobile:
            return
        self._vel += self._force / self.mass() * step
        self._pos += self._vel * step
        self._force += Vec[T, 3](0,0,0)

    fn mass(self) -> Scalar[T]:
        return self._geom.volume()

fn collision[T : DType](entity_a : Entity[T], entity_b : Entity[T]) -> Optional[CollisionRecord[T]]:
    return Optional[CollisionRecord[T]]()
