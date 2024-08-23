# TODO: Initial impl based on https://raytracing.github.io/books/RayTracingInOneWeekend.html#outputanimage

from math import sqrt


@value
struct Vec3[type: DType](Stringable):
    var _x: Scalar[type]
    var _y: Scalar[type]
    var _z: Scalar[type]

    fn __init__(inout self):
        self._x = 0
        self._y = 0
        self._z = 0

    fn __init__(inout self, x: Scalar[type], y: Scalar[type], z: Scalar[type]):
        self._x = x
        self._y = y
        self._z = z

    fn x(self) -> Scalar[type]:
        return self._x

    fn y(self) -> Scalar[type]:
        return self._y

    fn z(self) -> Scalar[type]:
        return self._z

    fn length_squared(self) -> Scalar[type]:
        return self._x**2 + self._y**2 + self._z**2

    fn length(self) -> SIMD[type, 1]:
        return sqrt(self.length_squared())

    fn dot(self, rhs: Self) -> SIMD[type, 1]:
        return self._x * rhs._x + self._y * rhs._y + self._z * rhs._z

    fn cross(self, rhs: Self) -> Self:
        return Self(
            self._y * rhs._z - self._z * rhs._y,
            self._z * rhs._x - self._x * rhs._z,
            self._x * rhs._y - self._y * rhs._x,
        )

    fn unit(self) -> Self:
        return self / self.length()

    fn __str__(self) -> String:
        """Readable representation of the vector."""
        return str(self.x()) + ", " + str(self.y()) + ", " + str(self.z())

    fn __repr__(self) -> String:
        """Unambiguous representation of the vector (c'tor syntax)."""
        return (
            "Vec3[DType."
            + str(type)
            + "]("
            + str(self.x())
            + ", "
            + str(self.y())
            + ", "
            + str(self.z())
            + "))"
        )

    # fn __lt__(self, rhs: Self) -> Bool:
    #     """Lexical comparison."""

    #     @parameter
    #     for i in range(Self.size):
    #         if self.e[i] < rhs.e[i]:
    #             return True
    #         elif self.e[i] > rhs.e[i]:
    #             return False
    #     return False

    # fn __le__(self, rhs: Self) -> Bool:
    #     """Lexical comparison."""

    #     @parameter
    #     for i in range(Self.size):
    #         if self.e[i] <= rhs.e[i]:
    #             return True
    #         elif self.e[i] > rhs.e[i]:
    #             return False
    #     return False

    # fn __eq__(self, rhs: Self) -> Bool:
    #     return SIMD.reduce_and(self.e == rhs.e)

    # fn __ne__(self, rhs: Self) -> Bool:
    #     return SIMD.reduce_or(self.e != rhs.e)

    # fn __gt__(self, rhs: Self) -> Bool:
    #     """Lexical comparison."""

    #     @parameter
    #     for i in range(Self.size):
    #         if self.e[i] > rhs.e[i]:
    #             return True
    #         elif self.e[i] < rhs.e[i]:
    #             return False
    #     return False

    # fn __ge__(self, rhs: Self) -> Bool:
    #     """Lexical comparison."""

    #     @parameter
    #     for i in range(Self.size):
    #         if self.e[i] >= rhs.e[i]:
    #             return True
    #         elif self.e[i] < rhs.e[i]:
    #             return False
    #     return False

    fn __add__(self, rhs: Self) -> Self:
        return Self(self.x() + rhs.x(), self.y() + rhs.y(), self.z() + rhs.z())

    fn __iadd__(inout self, rhs: Self):
        self = self + rhs

    fn __neg__(self) -> Self:
        return Self(-self.x(), -self.y(), -self.z())

    fn __sub__(self, rhs: Self) -> Self:
        return self + (-rhs)

    fn __isub__(inout self, rhs: Self):
        self = self - rhs

    fn __mul__(self, rhs: Scalar[type]) -> Self:
        return Self(self.x() * rhs, self.y() * rhs, self.z() * rhs)

    fn __rmul__(self, lhs: Scalar[type]) -> Self:
        return self * lhs

    fn __imul__(inout self, rhs: Scalar[type]):
        self = self * rhs

    fn __truediv__(self, rhs: Scalar[type]) -> Self:
        return Self(self.x() / rhs, self.y() / rhs, self.z() / rhs)

    fn __itruediv__(inout self, rhs: SIMD[type, 1]):
        self = self / rhs
