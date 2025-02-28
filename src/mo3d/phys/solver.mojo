from mo3d.phys.entity import CollisionRecord



# Need to specify as cant make trait generic over DType
trait PhysSolver(CollectionElement):
    fn solve(self, collision_record : CollisionRecord):
        ...

@value
struct PositionSolver(PhysSolver):
    fn solve(self, collision_record : CollisionRecord):
        alias T = collision_record.FloatType
        var diff = collision_record.pt_a_in_b - collision_record.pt_b_in_a
        if diff.length_squared() < 1e-4:
            return
        var a = collision_record.a_ptr[]
        var b = collision_record.b_ptr[]

        diff *= 0.8

        if a.mobile and b.mobile:
            var a_inv_mass = 1.0 / a.mass()
            var b_inv_mass = 1.0 / b.mass()
            diff /= (a_inv_mass + b_inv_mass)
            a.move_by(-diff * a_inv_mass)
            b.move_by(diff * b_inv_mass)
        elif a.mobile:
            a.move_by(-diff)
        elif b.mobile:
            b.move_by(diff)

