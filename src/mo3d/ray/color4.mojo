from math import sqrt


from mo3d.math.vec import Vec

alias Color4 = Vec[size=4]


fn linear_to_gamma[
    T: DType, size: Int = 1
](linear_component: SIMD[T, size]) -> SIMD[T, size]:
    if linear_component > 0:
        return sqrt(linear_component)
    return SIMD[T, size](0)
