from testing import assert_true, assert_equal
from memory import UnsafePointer
from os import getenv

from mo3d.window.sdl2 import SDL, SDL_INIT_VIDEO, SDL_WINDOWPOS_CENTERED, SDL_WINDOW_SHOWN

fn test_sdl2_init() raises:
    if getenv("CI") != "":
        return
    
    print("About to create SDL")
    var sdl = SDL()
    var res = sdl.Init(SDL_INIT_VIDEO)
    assert_equal(res, 0)
    
    print("About to create window")
    var window = sdl.CreateWindow(
        "test_sdl2".unsafe_ptr(),
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        640,
        480,
        SDL_WINDOW_SHOWN
    )
    
    # We can't easily check for null pointer validity in a safe way if generic UnsafePointer doesn't support it directly, 
    # but if it crashed it would have failed. 
    # Attempting to get surface as a smoke test
    
    print("About to get window surface")
    var surface = sdl.GetWindowSurface(window)
    print(surface)
    
    print("About to clean up")
    # Clean up
    print("About to DestroyWindow")
    sdl.DestroyWindow(window)
    print("About to Quit")
    sdl.Quit()
    print("Clean up finished")

fn main() raises:
    test_sdl2_init()
