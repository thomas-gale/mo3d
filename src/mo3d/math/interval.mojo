from math import inf


@value
@register_passable("trivial")
struct Interval[T: DType, simd_size: Int = 1](CollectionElementNew):
    alias S = SIMD[T, simd_size]
    var min: Self.S
    var max: Self.S

    # Default interval is empty
    fn __init__(inout self):
        self.min = Self.S(inf[T]())
        self.max = Self.S(-inf[T]())

    fn __init__(inout self: Interval[T, simd_size], /, *, other: Interval[T, simd_size]):
        self.min = other.min
        self.max = other.max

    @staticmethod
    fn empty() -> Self:
        return Self()

    @staticmethod
    fn universe() -> Self:
        return Self(-inf[T](), inf[T]())

    fn size(self) -> Self.S:
        return self.max - self.min

    fn contains(self, x: Self.S) -> SIMD[DType.bool, simd_size]:
        return (self.min <= x) and (x <= self.max)

    fn surrounds(self, x: Self.S) -> SIMD[DType.bool, simd_size]:
        return (self.min < x) and (x < self.max)

    fn clamp(self, x: Self.S) -> Self.S:
        if x < self.min:
            return self.min
        if x > self.max:
            return self.max
        return x

    fn expand(self, delta: Self.S) -> Self:
        return Self(self.min - delta, self.max + delta)
