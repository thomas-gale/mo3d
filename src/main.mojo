from algorithm import parallelize, vectorize
from complex import ComplexSIMD, ComplexFloat64
from math import iota
from tensor import Tensor
from testing import assert_equal

from mo3d.math.vec4 import Vec4

alias fps = 120
alias width = 256
alias height = 256
alias channels = Vec4[DType.float32].size

alias float_type = DType.float32
alias simd_width = 2 * simdwidthof[float_type]()


fn kernel_SIMD[
    simd_width: Int
](c: ComplexSIMD[float_type, simd_width]) -> SIMD[
    float_type, channels * simd_width
]:
    var cx = c.re
    var cy = c.im
    var r = cx / width
    var g = cy / height
    var b = cx / width
    var a = cy / height

    # Should be r1, g1, b1, a1, r2, g2, b2, a2, ...
    # Rebind is required to help the type checker understand the interleaving shape (4 * simd_width == 2 * 2 * simd_width)
    return rebind[SIMD[float_type, channels * simd_width]](
        (r.interleave(b)).interleave(g.interleave(a))
    )


fn main() raises:
    print("Hello, mo3d!")
    print("SIMD width:", simd_width)

    var t = Tensor[float_type](height, width, channels)
    print("Tensor shape:", t.shape())

    print("Goodbye, mo3d!")
