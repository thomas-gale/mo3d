from collections import InlineArray
from math.math import cos, sin

from mo3d.math.vec import Vec


from python import Python
from python import PythonObject


struct Mat[T: DType, dim: Int](Copyable, Movable):
    var _data: InlineArray[Scalar[Self.T], Self.dim * Self.dim]

    fn __init__(out self):
        self._data = InlineArray[Scalar[Self.T], Self.dim * Self.dim](
            unsafe_uninitialized=Self.True
        )
        for i in range(Self.dim):
            for j in range(Self.dim):
                self._data[i * Self.dim + j] = Scalar[Self.T](0)

    fn __init__(out self, *args: Vec[Self.T, Self.dim]):
        # We don't know for sure that the user has passed in the right number of Vecs, so we'll just initialize the matrix to 0 for safety.
        self._data = InlineArray[Scalar[Self.T], Self.dim * Self.dim](0.0)
        var i = 0
        for arg in args:
            for j in range(Self.dim):
                self._data[i * Self.dim + j] = arg[][j]
            i += 1

    @staticmethod
    fn eye() -> Self:
        var result = Self()
        for i in range(Self.dim):
            for j in range(Self.dim):
                if i == j:
                    result[i][j] = Scalar[Self.T](1)
                else:
                    result[i][j] = Scalar[Self.T](0)
        return result

    fn __getitem__(self, index: Int) -> Vec[Self.T, Self.dim]:
        var result = Vec[Self.T, Self.dim]()
        for i in range(Self.dim):
            result[i] = self._data[Self.dim * index + i]
        return result

    fn __setitem__(mut self, index: Int, value: Vec[Self.T, Self.dim]):
        for i in range(Self.dim):
            self._data[Self.dim * index + i] = value[i]

    fn __str__(self) -> String:
        var result = String("")
        for i in range(Self.dim):
            result += str(self[i]) + "\n"
        return result

    @staticmethod
    fn rotate_3(
        matrix: Self, angle_rads: Scalar[Self.T], axis: Vec[Self.T, Self.dim]
    ) raises -> Self:
        """
        Self.This just computes a 3D rotation.
        """
        if Self.dim != 3:
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

        var rotation_matrix = Mat[Self.T, Self.dim](
            Vec[Self.T, Self.dim](r11, r12, r13),
            Vec[Self.T, Self.dim](r21, r22, r23),
            Vec[Self.T, Self.dim](r31, r32, r33),
        )

        return Mat[Self.T, Self.dim](
            rotation_matrix * matrix[0],
            rotation_matrix * matrix[1],
            rotation_matrix * matrix[2],
        )

    fn __mul__(self, rhs: Vec[T, dim]) -> Vec[T, dim]:
        var result = Vec[T, dim]()
        @parameter
        for i in range(dim):
            result[i] = self[i].dot(rhs)
        return result

    fn mul_transpose(self, rhs: Vec[T, dim]) -> Vec[T, dim]:
        var result = Vec[T, dim]()
        @parameter
        for i in range(dim):
            @parameter
            for j in range(dim):
                result[i] += self._data[dim * j + i] * rhs[j]
        return result
    
    fn _dump_py_json(self) raises -> PythonObject:
        """
        Python object representing the item to dump out to json
        """
        var py_rows = Python.list()
        for i in range(dim):
            var py_row = Python.list()
            for j in range(dim):
                py_row.append(self._data[i * dim + j])
            py_rows.append(py_row)
        return py_rows

    @staticmethod
    fn _load_py_json(py_obj : PythonObject) raises -> Self:
        """
        Load from python object representing the item dumped out to json
        """
        var mat = Mat[T,dim]()
        for i in range(dim):
            var row = mat[i]
            for j in range(dim):
                mat._data[i * dim + j] = float(row[j]).cast[T]()
        return mat


# A matrix that we are asserting is a rotation matrix 
# (special orthogonal)
comptime RotMat = Mat
