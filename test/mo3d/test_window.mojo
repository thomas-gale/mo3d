from tensor import Tensor
from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.window.window import Window
from mo3d.window.sdl2_window import SDL2Window


fn test_sdl2_window() raises:
    var window = SDL2Window.create("test_create_window", 128, 128)
    assert_true(window.should_close() == False)
    var t = Tensor[DType.float32](128, 128, 4)
    window.redraw(t, 4)

# TODO - Can't run multiple window test without some form of mutex/sempahore
# fn test_create_sdl2_window() raises:
#     var window = SDL2Window.create("test_create_window", 128, 128)
#     assert_true(window.should_close() == False)

# fn test_redraw_sdl2_window() raises:
#     var window = SDL2Window.create("test_redraw_window", 128, 128)
#     var t = Tensor[DType.float32](128, 128, 4)
#     window.redraw(t, 4)
#     assert_true(window.should_close() == False)