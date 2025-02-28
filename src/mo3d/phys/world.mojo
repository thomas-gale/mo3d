from mo3d.phys.entity import Entity, CollisionRecord, collision
from mo3d.phys.solver import PhysSolver, PositionSolver

from mo3d.math.vec import Vec

@value 
struct World[T: DType, Solver : PhysSolver]:
    var _elements : List[Entity[T]]
    var _max_tick_length : Scalar[T]
    var _gravity : Vec[T, 3]
    var _solver : Solver

    fn __init__(inout self, solver : Solver):
        self._elements = List[Entity[T]]()
        self._max_tick_length = 0.01
        self._gravity = Vec[T, 3](0,0,-9.81)
        self._solver = solver

    fn simluate(inout self, time : Scalar[T]): 
        var curr_time : Scalar[T] = 0
        while curr_time < (time - self._max_tick_length):
            self.tick(self._max_tick_length)
        var rem = time - curr_time
        if rem > 1e-6:
            self.tick(rem)

    
    
    fn tick(inout self, step : Scalar[T]):
        var collisions = List[CollisionRecord[T]]()
        for i in range(len(self._elements)):
            for j in range(i, len(self._elements)):
                var col = collision(self._elements[i], self._elements[j])
                if col:
                    collisions.append(col.value())

        for col in collisions:
            self._solver.solve(col[])

        for elem in self._elements:
            elem[].apply_force(self._gravity)
            elem[].move(step)
        


    
        

