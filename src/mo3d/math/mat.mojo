from collections import InlinedFixedVector
from math.math import cos, sin
from random import random_float64

from mo3d.math.vec import Vec


@value
struct Mat[T: DType, dim: Int]:
    var _data: InlinedFixedVector[Scalar[T], dim * dim]

    fn __init__(inout self):
        self._data = InlinedFixedVector[Scalar[T], dim * dim](dim * dim)
        for i in range(dim * dim):
            self._data[i] = Scalar[T](0)

    fn __init__(inout self, *args: Vec[T, dim]):
        self._data = InlinedFixedVector[Scalar[T], dim * dim](dim * dim)
        var i = 0
        for arg in args:
            self._data[i] = arg[][i % dim]
            i += 1

    @staticmethod
    fn eye() -> Self:
        var result = Self()
        for i in range(dim):
            for j in range(dim):
                result._data[i * dim + j] = 1 if i == j else 0
        return result

    fn __getitem__(self, index: Int) -> Vec[T, dim]:
        var result = Vec[T, dim]()
        for i in range(index * dim, (index + 1) * dim):
            result[i] = self._data[index * dim + i]
        return result

    fn __setitem__(inout self, index: Int, value: Vec[T, dim]):
        for i in range(index * dim, (index + 1) * dim):
            self._data[index * dim + i] = value[i]

    @staticmethod
    fn rotate_3(
        matrix: Self, angle_rads: Scalar[T], axis: Vec[T, dim]
    ) raises -> Self:
        """
        This just computes a 3D rotation.
        """
        if dim != 3:
            raise Error("Rotation is only defined for 3D matrices.")

        c = cos(angle_rads)
        s = sin(angle_rads)
        var axis_norm = axis.unit()
        var ux = axis_norm[0]
        var uy = axis_norm[1]
        var uz = axis_norm[2]

        # Calculate rotation matrix components
        var r11 = c + ux * ux * (1 - c)
        var r12 = ux * uy * (1 - c) - uz * s
        var r13 = ux * uz * (1 - c) + uy * s

        var r21 = uy * ux * (1 - c) + uz * s
        var r22 = c + uy * uy * (1 - c)
        var r23 = uy * uz * (1 - c) - ux * s

        var r31 = uz * ux * (1 - c) - uy * s
        var r32 = uz * uy * (1 - c) + ux * s
        var r33 = c + uz * uz * (1 - c)

        var rotation_matrix = Mat[T, dim](
            Vec[T, dim](r11, r12, r13),
            Vec[T, dim](r21, r22, r23),
            Vec[T, dim](r31, r32, r33),
        )

        return Mat[T, dim](
            rotation_matrix * matrix[0],
            rotation_matrix * matrix[1],
            rotation_matrix * matrix[2],
        )

    fn __mul__(self, rhs: Vec[T, dim]) -> Vec[T, dim]:
        var result = Vec[T, dim]()
        for i in range(dim):
            result[i] = self[i].dot(rhs)
        return result
