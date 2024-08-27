from math import pi


fn degrees_to_radians[
    T: DType, size: Int
](degrees: SIMD[T, size]) -> SIMD[T, size]:
    return degrees * pi / 180.0
