# A simple Rng - for now use a shift generator see https://en.wikipedia.org/wiki/Xorshift

# The standard mojo random calls are system wide and lock if called rapidly from multiple threads
# This is designed to genrate float32 or float64 random numbers between 0 and 1 with an internal seed state.

struct Rng:
    var _internal : UInt64

    fn __init__(inout self, seed : UInt64 = 1):
        self._internal = seed
        # The period is 2^64 -1 however it has a fixed point at 0! - which internal cant be set to
        if self._internal == 0:
             self._internal = 1
        self._step()

    fn _step(inout self):
        var state : UInt64 = self._internal
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        self._internal = state

    fn float32(inout self) -> Float32:
        self._step()
        var denom : UInt64 = (1 << 23)
        var bits : UInt64 = self._internal & (denom - 1)
        return bits.cast[DType.float32]() / denom.cast[DType.float32]()

    fn float64(inout self) -> Float64:
        self._step()
        var denom : UInt64 = (1 << 52)
        var bits : UInt64 = self._internal & (denom - 1)
        return bits.cast[DType.float64]() / denom.cast[DType.float64]()


