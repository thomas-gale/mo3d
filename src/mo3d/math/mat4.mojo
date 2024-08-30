from math.math import cos, sin
from random import random_float64

from mo3d.math.vec4 import Vec4


@value
struct Mat4[type: DType]:
    alias size = 4
    alias S4 = SIMD[type, Self.size]

    var _u: Vec4[type]
    var _v: Vec4[type]
    var _w: Vec4[type]
    var _t: Vec4[type]

    @staticmethod
    fn eye() -> Self:
        return Mat4(
            Vec4(Self.S4(1, 0, 0, 0)),
            Vec4(Self.S4(0, 1, 0, 0)),
            Vec4(Self.S4(0, 0, 1, 0)),
            Vec4(Self.S4(0, 0, 0, 1)),
        )

    fn u(self) -> Vec4[type]:
        return self._u

    fn v(self) -> Vec4[type]:
        return self._v

    fn w(self) -> Vec4[type]:
        return self._w

    fn t(self) -> Vec4[type]:
        return self._t

    fn set_u(inout self, u: Vec4[type]) -> Self:
        self._u = u
        return self

    fn set_v(inout self, v: Vec4[type]) -> Self:
        self._v = v
        return self

    fn set_w(inout self, w: Vec4[type]) -> Self:
        self._w = w
        return self

    fn set_t(inout self, t: Vec4[type]) -> Self:
        self._t = t
        return self

    fn rotate(self, angle_rads: Scalar[type], axis: Vec4[type]) -> Mat4[type]:
        """
        This just computes a 3D rotation.
        """
        c = cos(angle_rads)
        s = sin(angle_rads)
        var axis_norm = axis.unit()
        var ux = axis_norm.x()
        var uy = axis_norm.y()
        var uz = axis_norm.z()
        # var uw = axis_norm.w()

        # Calculate rotation matrix components
        var r11 = c + ux * ux * (1 - c)
        var r12 = ux * uy * (1 - c) - uz * s
        var r13 = ux * uz * (1 - c) + uy * s
        var r14 = 0

        var r21 = uy * ux * (1 - c) + uz * s
        var r22 = c + uy * uy * (1 - c)
        var r23 = uy * uz * (1 - c) - ux * s
        var r24 = 0

        var r31 = uz * ux * (1 - c) - uy * s
        var r32 = uz * uy * (1 - c) + ux * s
        var r33 = c + uz * uz * (1 - c)
        var r34 = 0

        var r41 = 0
        var r42 = 0
        var r43 = 0
        var r44 = 1

        # Construct the rotation matrix
        var rotation_matrix = Mat4(
            Vec4(Self.S4(r11, r12, r13, r14)),
            Vec4(Self.S4(r21, r22, r23, r24)),
            Vec4(Self.S4(r31, r32, r33, r34)),
            Vec4(Self.S4(r41, r42, r43, r44)),
        )

        return Mat4(
            rotation_matrix * self._u,
            rotation_matrix * self._v,
            rotation_matrix * self._w,
            # Vec4(Self.S4(0, 0, 0, 1)),
            rotation_matrix * self._t,
        )

    fn __mul__(self, rhs: Vec4[type]) -> Vec4[type]:
        return Vec4(
            Self.S4(
                self._u.dot(rhs),
                self._v.dot(rhs),
                self._w.dot(rhs),
                self._t.dot(rhs),
            )
        )

    fn __str__(self) -> String:
        return (
            "u: "
            + str(self._u)
            + "\n"
            + "v: "
            + str(self._v)
            + "\n"
            + "w: "
            + str(self._w)
            + "\n"
            + "t: "
            + str(self._t)
        )
