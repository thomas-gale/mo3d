# TODO: Initial impl based on https://raytracing.github.io/books/RayTracingInOneWeekend.html#outputanimage

from math import sqrt
from random import random_float64


@value
struct Vec4[type: DType](EqualityComparable, Stringable):
    alias size = 4
    alias S4 = SIMD[type, Self.size]

    var e: Self.S4

    fn __init__(inout self):
        self.e = SIMD[type, 4](0)

    fn __init__(inout self, e: SIMD[type, 1]):
        self.e = SIMD[type, 4](e)

    fn x(self) -> SIMD[type, 1]:
        return self.e[0]

    fn y(self) -> SIMD[type, 1]:
        return self.e[1]

    fn z(self) -> SIMD[type, 1]:
        return self.e[2]

    fn w(self) -> SIMD[type, 1]:
        return self.e[3]

    fn length_squared(self) -> SIMD[type, 1]:
        return SIMD.reduce_add(self.e * self.e)

    fn length(self) -> SIMD[type, 1]:
        return sqrt(self.length_squared())

    fn dot(self, rhs: Self) -> SIMD[type, 1]:
        return SIMD.reduce_add(self.e * rhs.e)

    fn cross(self, rhs: Self) -> Self:
        return Self(
            SIMD[type, Self.size](
                self.e[1] * rhs.e[2] - self.e[2] * rhs.e[1],
                self.e[2] * rhs.e[0] - self.e[0] * rhs.e[2],
                self.e[0] * rhs.e[1] - self.e[1] * rhs.e[0],
            )
        )

    fn unit(self) -> Self:
        return self / self.length()

    @staticmethod
    fn random_in_unit_sphere() -> Self:
        while True:
            var p = Self.random(-1, 1)
            if p.length_squared() < 1:
                return p

    @staticmethod
    fn random_unit_vector() -> Self:
        return Self.random_in_unit_sphere().unit()

    @staticmethod
    fn random_on_hemisphere(normal: Self) -> Self:
        var on_unit_sphere = Self.random_unit_vector()
        if on_unit_sphere.dot(normal) > 0:
            # In the same hemisphere as the normal
            return on_unit_sphere
        else:
            return -on_unit_sphere

    @staticmethod
    fn random() -> Self:
        return Self(
            Self.S4(
                random_float64().cast[type](),
                random_float64().cast[type](),
                random_float64().cast[type](),
                random_float64().cast[type](),
            )
        )

    @staticmethod
    fn random(min: Scalar[type], max: Scalar[type]) -> Self:
        var min_64 = min.cast[DType.float64]()
        var max_64 = max.cast[DType.float64]()
        return Self(
            Self.S4(
                random_float64(min_64, max_64).cast[type](),
                random_float64(min_64, max_64).cast[type](),
                random_float64(min_64, max_64).cast[type](),
                random_float64(min_64, max_64).cast[type](),
            )
        )

    fn __str__(self) -> String:
        """Readable representation of the vector."""
        return (
            str(self.x())
            + ", "
            + str(self.y())
            + ", "
            + str(self.z())
            + ", "
            + str(self.w())
        )

    fn __repr__(self) -> String:
        """Unambiguous representation of the vector (c'tor syntax)."""
        return (
            "Vec4(SIMD[DType."
            + str(type)
            + ", "
            + str(Self.size)
            + "]("
            + str(self.x())
            + ", "
            + str(self.y())
            + ", "
            + str(self.z())
            + ", "
            + str(self.w())
            + "))"
        )

    fn __getitem__(self, index: Int) -> SIMD[type, 1]:
        return self.e[index]

    fn __setitem__(inout self, index: Int, value: SIMD[type, 1]):
        self.e[index] = value

    fn __lt__(self, rhs: Self) -> Bool:
        """Lexical comparison."""

        @parameter
        for i in range(Self.size):
            if self.e[i] < rhs.e[i]:
                return True
            elif self.e[i] > rhs.e[i]:
                return False
        return False

    fn __le__(self, rhs: Self) -> Bool:
        """Lexical comparison."""

        @parameter
        for i in range(Self.size):
            if self.e[i] <= rhs.e[i]:
                return True
            elif self.e[i] > rhs.e[i]:
                return False
        return False

    fn __eq__(self, rhs: Self) -> Bool:
        return SIMD.reduce_and(self.e == rhs.e)

    fn __ne__(self, rhs: Self) -> Bool:
        return SIMD.reduce_or(self.e != rhs.e)

    fn __gt__(self, rhs: Self) -> Bool:
        """Lexical comparison."""

        @parameter
        for i in range(Self.size):
            if self.e[i] > rhs.e[i]:
                return True
            elif self.e[i] < rhs.e[i]:
                return False
        return False

    fn __ge__(self, rhs: Self) -> Bool:
        """Lexical comparison."""

        @parameter
        for i in range(Self.size):
            if self.e[i] >= rhs.e[i]:
                return True
            elif self.e[i] < rhs.e[i]:
                return False
        return False

    fn __add__(self, rhs: Self) -> Self:
        return Self(self.e + rhs.e)

    fn __iadd__(inout self, rhs: Self):
        self.e += rhs.e

    fn __neg__(self) -> Self:
        return Self(-self.e)

    fn __sub__(self, rhs: Self) -> Self:
        return Self(self.e - rhs.e)

    fn __isub__(inout self, rhs: Self):
        self.e -= rhs.e

    fn __mul__(self, rhs: SIMD[type, 1]) -> Self:
        return Self(self.e * rhs)

    fn __rmul__(self, lhs: SIMD[type, 1]) -> Self:
        return Self(self.e * lhs)

    fn __imul__(inout self, rhs: SIMD[type, 1]):
        self.e *= rhs

    fn __truediv__(self, rhs: SIMD[type, 1]) -> Self:
        return Self(self.e / rhs)

    fn __itruediv__(inout self, rhs: SIMD[type, 1]):
        self.e /= rhs
