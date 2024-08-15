# TODO: Initial impl based on https://raytracing.github.io/books/RayTracingInOneWeekend.html#outputanimage


@value
struct Vec4[type: DType]():
    var data: SIMD[type, size=4]

    fn x(self) -> SIMD[type, 1]:
        return self.data[0]

    fn y(self) -> SIMD[type, 1]:
        return self.data[1]

    fn z(self) -> SIMD[type, 1]:
        return self.data[2]

    fn w(self) -> SIMD[type, 1]:
        return self.data[3]
