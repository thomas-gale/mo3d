from math import inf


@value
struct Interval[T: DType, simd_size: Int = 1](CollectionElementNew):
    alias S = SIMD[T, simd_size]
    var min: Self.S
    var max: Self.S

    fn __init__(inout self):
        """
        Default constructor (empty interval).
        """
        self.min = Self.S(inf[T]())
        self.max = Self.S(-inf[T]())

    fn __init__(inout self, other: Self):
        """
        Copy constructor.
        """
        self.min = other.min
        self.max = other.max

    fn __init__(inout self, a: Self, b: Self):
        """
        Construct interval tightly bounding two intervals.
        """
        self.min = min(a.min, b.min)
        self.max = max(a.max, b.max)

    @staticmethod
    fn empty() -> Self:
        return Self()

    @staticmethod
    fn universe() -> Self:
        return Self(-inf[T](), inf[T]())

    fn __str__(self) -> String:
        return "Interval(" + str(self.min) + ", " + str(self.max) + ")"

    fn __add__(self, delta: Self.S) -> Self:
        return Self(self.min + delta, self.max + delta)

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
