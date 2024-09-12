from mo3d.math.vec import Vec

alias ComponentID = Int

trait Component:
    fn __init__(inout self, other: Component):
        ...


    fn component_type(self) -> String:
        ...


struct VecComponent[T: DType, dim: Int](Component):
    var vec: Vec[T, dim]

    fn __init__(inout self, vec: Vec[T, dim]):
        self.vec = vec

    fn __init__(inout self, other: Component):
        if other.component_type() != "Vec":
            raise ValueError("Cannot initialize VecComponent with non-Vec component")
        self.vec = other.vec


    fn component_type(self) -> String:
        return "Vec"
