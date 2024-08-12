from mo3d.numeric import Numeric


@value
struct NumericFloat32(Numeric):
    var value: Float32

    fn __init__(inout self, value: Float64):
        self.value = value

    fn __add__(self, other: Self) -> Self:
        return self.value + other.value

    fn __iadd__(inout self: Self, other: Self):
        self.value += other.value

    fn __sub__(self, other: Self) -> Self:
        return self.value - other.value

    fn __isub__(inout self: Self, other: Self):
        self.value -= other.value

    fn __mul__(self, other: Self) -> Self:
        return self.value * other.value

    fn __imul__(inout self: Self, other: Self):
        self.value *= other.value

    fn __pow__(self, other: Float32) -> Self:
        return self.value**other

    fn __lt__(self, other: Self) -> Bool:
        return self.value < other.value

    fn __gt__(self, other: Self) -> Bool:
        return self.value > other.value

    fn __le__(self, other: Self) -> Bool:
        return self.value <= other.value

    fn __ge__(self, other: Self) -> Bool:
        return self.value >= other.value

    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __ne__(self, other: Self) -> Bool:
        return self.value != other.value

    fn __str__(self) -> String:
        return str(self.value)
