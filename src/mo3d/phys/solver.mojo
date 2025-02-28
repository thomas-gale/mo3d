from mo3d.phys.entity import CollisionRecord



# Need to specify as cant make trait generic over DType
trait PhysSolver(CollectionElement):
    fn solve(self, collision_record : CollisionRecord):
        ...

@value
struct PositionSolver(PhysSolver):
    fn solve(self, collision_record : CollisionRecord):
        pass