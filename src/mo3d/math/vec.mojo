from algorithm import parallelize
from collections import InlineArray
from math import sqrt
from random import random_float64

struct Vec[T: DType, size: Int](EqualityComparable, Stringable):
    var _data: InlineArray[Scalar[T], size]

    fn __init__(inout self):
        self._data = InlineArray[Scalar[T], size](0.0)

    fn __init__(inout self, owned data: InlineArray[Scalar[T], size]):
        self._data = data

    fn __init__(inout self, owned *args: Scalar[T]):
        self._data = InlineArray[Scalar[T], size](unsafe_uninitialized=True)
        var i = 0
        for arg in args:
            self._data[i] = arg[]
            i += 1

    fn __copyinit__(inout self, other: Self):
        self._data = other._data

    fn __moveinit__(inout self, owned other: Self):
        self._data = other._data^

    fn clone(self) -> Self:
        var result = Self()
        result._data = self._data
        return result

    fn __getitem__(self, index: Int) -> Scalar[T]:
        return self._data[index]

    fn __setitem__(inout self, index: Int, value: SIMD[T, 1]):
        self._data[index] = value

    fn dot(self, rhs: Self) -> SIMD[T, 1]:
        var sum: Scalar[T] = 0
        for i in range(size):
            sum += self._data[i] * rhs._data[i]
        return sum

    fn length_squared(self) -> Scalar[T]:
        return self.dot(self)

    fn length(self) -> SIMD[T, 1]:
        return sqrt(self.length_squared())

    fn near_zero[tol: Scalar[T] = 1e-8](self) -> Bool:
        for i in range(size):
            if abs(self._data[i]) > tol:
                return False
        return True

    @staticmethod
    fn cross_3(lhs: Self, rhs: Self) raises -> Self:
        """
        Cross product of two 3D vectors.
        It will raise an error if the vectors are not 3D.
        """
        if size != 3:
            raise Error("Cross product is only defined for 3D vectors.")
        return Self(
            lhs._data[1] * rhs._data[2] - lhs._data[2] * rhs._data[1],
            lhs._data[2] * rhs._data[0] - lhs._data[0] * rhs._data[2],
            lhs._data[0] * rhs._data[1] - lhs._data[1] * rhs._data[0],
        )

    fn unit(self) -> Self:
        return self / self.length()

    @staticmethod
    fn random_in_unit_disk() -> Self:
        while True:
            var p = Self.random(-1, 1)
            p[2] = 0
            if p.length_squared() < 1:
                return p

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
    fn reflect(v: Self, n: Self) -> Self:
        return v - 2 * v.dot(n) * n


    @staticmethod
    fn refract(uv: Self, n: Self, etai_over_etat: Scalar[T]) -> Self:
        var cos_theta = min(-uv.dot(n), 1.0)
        var r_out_perp = etai_over_etat * (uv + cos_theta * n)
        var r_out_parallel = -sqrt(abs(1.0 - r_out_perp.length_squared())) * n
        return r_out_perp + r_out_parallel

    @staticmethod
    fn random() -> Self:
        var data = InlineArray[Scalar[T], size](unsafe_uninitialized=True)
        for i in range(size):
            data[i] = random_float64().cast[T]()
        return Self(data)

    @staticmethod
    fn random(min: Scalar[T], max: Scalar[T]) -> Self:
        var min_64 = min.cast[DType.float64]()
        var max_64 = max.cast[DType.float64]()
        var data = InlineArray[Scalar[T], size](unsafe_uninitialized=True)
        for i in range(size):
            data[i] = random_float64(min_64, max_64).cast[T]()
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
            result._data[i] = self._data[i] + rhs._data[i]
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
            result._data[i] = self._data[i] - rhs._data[i]
        return result

    fn __isub__(inout self, rhs: Self):
        for i in range(size):
            self._data[i] -= rhs._data[i]

    fn __mul__(self, rhs: Self) -> Self:
        var result = Self()
        for i in range(size):
            result._data[i] = self._data[i] * rhs._data[i]
        return result

    fn __mul__(self, rhs: SIMD[T, 1]) -> Self:
        var result = Self()
        for i in range(size):
            result._data[i] = self._data[i] * rhs
        return result

    fn __rmul__(self, lhs: SIMD[T, 1]) -> Self:
        return self * lhs

    fn __imul__(inout self, rhs: SIMD[T, 1]):
        for i in range(size):
            self._data[i] *= rhs

    fn __truediv__(self, rhs: SIMD[T, 1]) -> Self:
        var result = Self()
        for i in range(size):
            result._data[i] = self._data[i] / rhs
        return result

    fn __itruediv__(inout self, rhs: SIMD[T, 1]):
        for i in range(size):
            self._data[i] /= rhs
