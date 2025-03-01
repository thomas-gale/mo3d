from mo3d.phys.entity import PhysEntity, CollisionRecord, collision
from mo3d.phys.solver import PhysSolver, PositionSolver

from mo3d.math.vec import Vec

from mo3d.ecs.component_store import ComponentStore, ComponentType

@value
struct World[T: DType, Solver : PhysSolver]:
    var _elements : List[PhysEntity[T]]
    var _max_tick_length : Scalar[T]
    var _gravity : Vec[T, 3]
    var _solver : Solver

    fn __init__(mut self, solver : Solver):
        self._elements = List[PhysEntity[T]]()
        self._max_tick_length = 0.01
        self._gravity = Vec[T, 3](0,0,-9.81)
        self._solver = solver

    fn simluate(mut self, time : Scalar[T]): 
        var curr_time : Scalar[T] = 0
        while curr_time < (time - self._max_tick_length):
            self.tick(self._max_tick_length)
        var rem = time - curr_time
        if rem > 1e-6:
            self.tick(rem)
    
    fn tick(mut self, step : Scalar[T]):
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

# This currently blocks but could run async
fn run_physics_store[
    T: DType, dim: Int
](mut store: ComponentStore[T, dim], time : Scalar[T]) raises:
    # We can only do physics on a 3D store
    @parameter
    if dim != 3:
        return
    var store3 = rebind[ComponentStore[T, 3]](store)
    var solver = PositionSolver()
    var world = World[T](solver)
    for entity_id in store3.get_entities_with_components(ComponentType.Position):
        var phys = store3.physics_components[
            store3.entity_to_components[entity_id[]][ComponentType.PhysicsComponent]
        ]
        var pos = store3.position_components[
            store3.entity_to_components[entity_id[]][ComponentType.Position]
        ]
        var phys_entity = PhysEntity[T](
            entity_id[],
            phys._geom,
            pos,
            Vec[T, 3](0,0,0),
            Vec[T, 3](0,0,0),
            phys._mobile
        )
        world._elements.append(phys_entity)

    print("Setup")
    #world.simluate(time)

    # Update store
    for elem in world._elements:
        store3.position_components[
            store3.entity_to_components[elem[]._id][ComponentType.Position]
        ] = elem[]._pos
    
        

