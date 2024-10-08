from algorithm import parallelize, vectorize
from memory import UnsafePointer

from mo3d.math.interval import Interval
from mo3d.ray.color4 import linear_to_gamma
from mo3d.camera.camera import Camera
from mo3d.window.window import Window
from mo3d.window.sdl2 import (
    SDL_INIT_VIDEO,
    SDL_PIXELFORMAT_RGBA8888,
    SDL_QUIT,
    SDL_MOUSEMOTION,
    SDL_MOUSEBUTTONDOWN,
    SDL_MOUSEBUTTONUP,
    SDL_MOUSEWHEEL,
    SDL_TEXTUREACCESS_STREAMING,
    SDL_WINDOWPOS_CENTERED,
    SDL_WINDOW_SHOWN,
    SDL,
    SDL_Rect,
    SDL_Renderer,
    SDL_Texture,
    SDL_Window,
    Event,
)


struct SDL2Window(Window):
    var _name: String
    var _height: Int
    var _width: Int

    var _sdl: SDL
    var _window: UnsafePointer[SDL_Window]
    var _renderer: UnsafePointer[SDL_Renderer]
    var _display_texture: UnsafePointer[SDL_Texture]

    var _event: Event

    fn __init__(
        inout self, name: String, width: Int, height: Int
    ) raises -> None:
        self._name = name
        self._width = width
        self._height = height
        print("Creating SDL2 window '" + name + "' of size", width, "x", height)

        self._sdl = SDL()
        var res_code = self._sdl.Init(SDL_INIT_VIDEO)
        if res_code != 0:
            raise Error("Failed to initialize SDL2")
        print("SDL2 initialized")

        self._window = self._sdl.CreateWindow(
            self._name.unsafe_ptr(),
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            self._width,
            self._height,
            SDL_WINDOW_SHOWN,
        )
        print("SDL2 window created")

        if self._window == UnsafePointer[SDL_Window]():
            raise Error("Failed to create SDL window")

        self._renderer = self._sdl.CreateRenderer(self._window, -1, 0)

        self._display_texture = self._sdl.CreateTexture(
            self._renderer,
            SDL_PIXELFORMAT_RGBA8888,
            SDL_TEXTUREACCESS_STREAMING,
            width,
            height,
        )

        self._event = Event()

        print("Window", self._window)
        print("Renderer", self._renderer)
        print("Display texture", self._display_texture)

    fn __del__(owned self) -> None:
        self._sdl.DestroyTexture(self._display_texture)
        print("Texture destroyed")
        self._sdl.DestroyRenderer(self._renderer)
        print("Renderer destroyed")
        self._sdl.DestroyWindow(self._window)
        print("Window destroyed")
        self._sdl.Quit()
        print("SDL2 quit")

    @staticmethod
    fn create(name: String, height: Int, width: Int) raises -> Self:
        return SDL2Window(name, height, width)

    fn process_events(inout self, inout camera: Camera) -> Bool:
        """
        Process all SDL2 events, setting state on the camera (TODO: should this be decoupled?) and return True if the window should remain open.
        """
        while (
            self._sdl.PollEvent(UnsafePointer[Event].address_of(self._event))
            != 0
        ):
            if self._event.type == SDL_QUIT:
                return False

            try:
                if self._event.type == SDL_MOUSEBUTTONDOWN:
                    var button = self._event.as_mousebutton()
                    camera.start_dragging(button[].x, button[].y)
                if self._event.type == SDL_MOUSEBUTTONUP:
                    camera.stop_dragging()
                if self._event.type == SDL_MOUSEMOTION:
                    var motion = self._event.as_mousemotion()
                    camera.arcball(motion[].x, motion[].y)
            except Error:
                print("Failed to cast event")

        return True

    fn redraw[
        float_type: DType
    ](
        self, t: UnsafePointer[Scalar[float_type]], channels: Int = 4
    ) raises -> None:
        _ = self._sdl.RenderClear(self._renderer)

        # These pixels are in GPU memory - we cant use SIMD as we don't know if SDL2 has aligned them
        var pixels = UnsafePointer[SIMD[DType.uint8, 1]]()
        # This value doesn't seem to be at a sensible address - 0x400 (Is this SDL2's null pointer?)
        var pitch = UnsafePointer[Int32]()
        # Manually set the pitch to the width * 4 (4 channels)
        var manual_pitch = self._width * channels
        var lock_code = self._sdl.LockTexture(
            self._display_texture, UnsafePointer[SDL_Rect](), pixels, pitch
        )

        if lock_code != 0:
            raise Error(
                "Failed to lock texture: "
                + str(lock_code)
                + self._sdl.get_sdl_error_as_string()
            )

        @parameter
        fn draw_row(y: Int):
            @parameter
            fn draw_row_vectorize[simd_width: Int](x: Int):
                # Calculate the correct offset using pitch
                var offset = y * manual_pitch + x * channels

                var r = linear_to_gamma((t + offset + 3)[])
                var g = linear_to_gamma((t + offset + 2)[])
                var b = linear_to_gamma((t + offset + 1)[])
                var a = linear_to_gamma((t + offset)[])

                # Translate all 0-1 values to 0-255 and cast to uint8
                var intensity = Interval[float_type](0.000, 0.999)
                (pixels + offset)[] = (intensity.clamp(a) * 256).cast[
                    DType.uint8
                ]()  # A
                (pixels + offset + 1)[] = (intensity.clamp(b) * 256).cast[
                    DType.uint8
                ]()  # B
                (pixels + offset + 2)[] = (intensity.clamp(g) * 256).cast[
                    DType.uint8
                ]()  # G
                (pixels + offset + 3)[] = (intensity.clamp(r) * 256).cast[
                    DType.uint8
                ]()  # R

            # This vectorize is kinda pointless (using a simd_width of 1). But it's here to show that, if we could ensure the texture is aligned (e.g. use a library ), we can use SIMD here.
            vectorize[draw_row_vectorize, 1](self._width)

        # We get errors if the number of workers is greater than 1 when inside the main loop
        parallelize[draw_row](self._height, self._height)

        self._sdl.UnlockTexture(self._display_texture)

        # Convince mojo not to mess with these pointers (which don't even belong to us!) before we've unlocked the texture
        _ = pixels
        _ = pitch
        _ = manual_pitch  # This is here to convince mojo not to delete this prematurely and break the parallelized redraw (spooky)

        _ = self._sdl.RenderCopy(self._renderer, self._display_texture, 0, 0)
        _ = self._sdl.RenderPresent(self._renderer)
