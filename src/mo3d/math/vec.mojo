from algorithm import parallelize
from collections import InlinedFixedVector
from math import sqrt
from random import random_float64


@value
struct Vec[type: DType, size: Int](EqualityComparable, Stringable):
    var _data: InlinedFixedVector[Scalar[type], size]

    fn __init__(inout self):
        self._data = InlinedFixedVector[Scalar[type], size](size)

    fn __init__(inout self, *args: Scalar[type]):
        self._data = InlinedFixedVector[Scalar[type], size](size)
        for i in range(size):
            self._data[i] = args[i]

    fn __getitem__(self, index: Int) -> Scalar[type]:
        return self._data[index]

    fn __setitem__(inout self, index: Int, value: SIMD[type, 1]):
        self._data[index] = value

    fn dot(self, rhs: Self) -> SIMD[type, 1]:
        var sum: Scalar[type] = 0
        for i in range(size):
            sum += self._data[i] * rhs._data[i]
        return sum

    fn length_squared(self) -> Scalar[type]:
        return self.dot(self)

    fn length(self) -> SIMD[type, 1]:
        return sqrt(self.length_squared())

    fn cross(self, rhs: Self) raises -> Self:
        @parameter
        if size == 3:
            return Self(
                self._data[1] * rhs._data[2] - self._data[2] * rhs._data[1],
                self._data[2] * rhs._data[0] - self._data[0] * rhs._data[2],
                self._data[0] * rhs._data[1] - self._data[1] * rhs._data[0],
            )
        else:
            raise Error("Cross product is only defined for 3D vectors.")

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
        var data = InlinedFixedVector[Scalar[type], size](size)
        for i in range(size):
            data[i] = random_float64().cast[type]()
        return Self(data)

    @staticmethod
    fn random(min: Scalar[type], max: Scalar[type]) -> Self:
        var min_64 = min.cast[DType.float64]()
        var max_64 = max.cast[DType.float64]()
        var data = InlinedFixedVector[Scalar[type], size](size)
        for i in range(size):
            data[i] = random_float64(min_64, max_64).cast[type]()
        return Self(data)

    fn __str__(self) -> String:
        """Readable representation of the vector."""
        var result = String("")
        for i in range(size):
            result += str(self._data[i])
            if i < size - 1:
                result += ", "
        return result

    fn __lt__(self, rhs: Self) -> Bool:
        """Lexical comparison."""

        @parameter
        for i in range(Self.size):
            if self._data[i] < rhs._data[i]:
                return True
            elif self._data[i] > rhs._data[i]:
                return False
        return False

    fn __le__(self, rhs: Self) -> Bool:
        """Lexical comparison."""

        @parameter
        for i in range(Self.size):
            if self._data[i] <= rhs._data[i]:
                return True
            elif self._data[i] > rhs._data[i]:
                return False
        return False

    fn __eq__(self, rhs: Self) -> Bool:
        for i in range(size):
            if self._data[i] != rhs._data[i]:
                return False
        return True

    fn __ne__(self, rhs: Self) -> Bool:
        for i in range(size):
            if self._data[i] != rhs._data[i]:
                return True
        return False

    fn __gt__(self, rhs: Self) -> Bool:
        """Lexical comparison."""

        @parameter
        for i in range(Self.size):
            if self._data[i] > rhs._data[i]:
                return True
            elif self._data[i] < rhs._data[i]:
                return False
        return False

    fn __ge__(self, rhs: Self) -> Bool:
        """Lexical comparison."""

        @parameter
        for i in range(Self.size):
            if self._data[i] >= rhs._data[i]:
                return True
            elif self._data[i] < rhs._data[i]:
                return False
        return False

    fn __add__(self, rhs: Self) -> Self:
        var result = Self()
        for i in range(size):
            result._data[i] += rhs._data[i]
        return result

    fn __iadd__(inout self, rhs: Self):
        for i in range(size):
            self._data[i] += rhs._data[i]

    fn __neg__(self) -> Self:
        var result = Self()
        for i in range(size):
            result._data[i] = -self._data[i]
        return result

    fn __sub__(self, rhs: Self) -> Self:
        var result = Self()
        for i in range(size):
            result._data[i] -= rhs._data[i]
        return result

    fn __isub__(inout self, rhs: Self):
        for i in range(size):
            self._data[i] -= rhs._data[i]

    fn __mul__(self, rhs: SIMD[type, 1]) -> Self:
        var result = Self()
        for i in range(size):
            result._data[i] = self._data[i] * rhs
        return result

    fn __rmul__(self, lhs: SIMD[type, 1]) -> Self:
        return self * lhs

    fn __imul__(inout self, rhs: SIMD[type, 1]):
        for i in range(size):
            self._data[i] *= rhs

    fn __truediv__(self, rhs: SIMD[type, 1]) -> Self:
        var result = Self()
        for i in range(size):
            result._data[i] = self._data[i] / rhs
        return result

    fn __itruediv__(inout self, rhs: SIMD[type, 1]):
        for i in range(size):
            self._data[i] /= rhs
