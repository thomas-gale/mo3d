from math.math import cos, sin
from random import random_float64

from mo3d.math.vec4 import Vec4


@value
struct Mat4[type: DType]:
    alias size = 4
    alias S4 = SIMD[type, Self.size]

    var u: Vec4[type]
    var v: Vec4[type]
    var w: Vec4[type]
    var t: Vec4[type]

    @staticmethod
    fn eye() -> Self:
        return Mat4(
            Vec4(Self.S4(1, 0, 0, 0)),
            Vec4(Self.S4(0, 1, 0, 0)),
            Vec4(Self.S4(0, 0, 1, 0)),
            Vec4(Self.S4(0, 0, 0, 1)),
        )

    fn rotate(
        self, angle_rads: Scalar[type], axis: Vec4[type]
    ) -> Mat4[type]:
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
            rotation_matrix * self.u,
            rotation_matrix * self.v,
            rotation_matrix * self.w,
            rotation_matrix * self.t,
        )

    fn __mul__(self, rhs: Vec4[type]) -> Vec4[type]:
        return Vec4(
            Self.S4(
                self.u.dot(rhs),
                self.v.dot(rhs),
                self.w.dot(rhs),
                self.t.dot(rhs),
            )
        )

    fn __str__(self) -> String:
        return (
            "u: "
            + str(self.u)
            + "\n"
            + "v: "
            + str(self.v)
            + "\n"
            + "w: "
            + str(self.w)
            + "\n"
            + "t: "
            + str(self.t)
        )
