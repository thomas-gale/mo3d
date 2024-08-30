from tensor import Tensor
from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.window.window import Window
from mo3d.window.sdl2_window import SDL2Window


fn test_create_sdl2_window() raises:
    var window = SDL2Window.create("test_create_window", 128, 128)
    assert_equal(window._height, 128)
    assert_equal(window._width, 128)

fn test_redraw_sdl2_window() raises:
    var window = SDL2Window.create("test_redraw_window", 128, 128)
    var t = UnsafePointer[Scalar[DType.float32]].alloc(128*128*4)
    window.redraw(t, 4)
    assert_equal(window._height, 128)
    assert_equal(window._width, 128)
