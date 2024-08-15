# TODO: Initial impl based on https://raytracing.github.io/books/RayTracingInOneWeekend.html#outputanimage

from math import sqrt

@value
struct Vec4[type: DType]():
    var data: SIMD[type, size=4]

    fn __init__(inout self):
        self.data = SIMD[type, 4](0)  # Value is splatted

    fn x(self) -> SIMD[type, 1]:
        return self.data[0]

    fn y(self) -> SIMD[type, 1]:
        return self.data[1]

    fn z(self) -> SIMD[type, 1]:
        return self.data[2]

    fn w(self) -> SIMD[type, 1]:
        return self.data[3]

    fn __getitem__(self, index: Int) -> SIMD[type, 1]:
        return self.data[index]

    fn __setitem__(inout self, index: Int, value: SIMD[type, 1]):
        self.data[index] = value

    fn __neg__(self) -> Self:
        return Self(-self.data)

    fn __sub__(self, other: Self) -> Self:
        return Self(self.data - other.data)

    fn __iadd__(inout self, other: Self):
        self.data += other.data

    fn __imul__(inout self, other: Self):
        self.data *= other.data

    fn __idiv__(inout self, other: Self):
        self.data /= other.data

    fn length_squared(self) -> SIMD[type, 1]:
        return SIMD.reduce_add(self.data * self.data)

    fn length(self) -> SIMD[type, 1]:
        return sqrt(self.length_squared())
