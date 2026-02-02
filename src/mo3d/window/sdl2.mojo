# Attribution: https://github.com/msteele/mojo-sdl/tree/main

from memory import UnsafePointer, alloc
from sys.ffi import OwnedDLHandle, DLHandle
from sys import ffi, info, simdwidthof

comptime CPtr[T: AnyType] = UnsafePointer[T, origin=MutExternalOrigin]
comptime CPtrRO[T: AnyType] = UnsafePointer[T, origin=ImmutAnyOrigin]


from os import getenv
from python import Python

fn get_sdl_lib_path() -> String:
    return getenv("CONDA_PREFIX") + "/lib/libSDL2.so"

comptime SDL_PIXELTYPE_PACKED32 = 6
comptime SDL_PACKEDORDER_RGBA = 4
comptime SDL_PACKEDLAYOUT_8888 = 6


fn SDL_DEFINE_PIXELFORMAT(
    type: Int, order: Int, layout: Int, bits: Int, bytes: Int
) -> Int:
    return (
        (1 << 28)
        | ((type) << 24)
        | ((order) << 20)
        | ((layout) << 16)
        | ((bits) << 8)
        | ((bytes) << 0)
    )


comptime SDL_PIXELFORMAT_RGBA8888 = SDL_DEFINE_PIXELFORMAT(
    SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4
)

comptime SDL_TEXTUREACCESS_STREAMING = 1
comptime SDL_TEXTUREACCESS_TARGET = 2

comptime SDL_INIT_VIDEO = 0x00000020


struct SDL_Window:
    pass



struct SDL_Rect:
    var x: Int32
    var y: Int32
    var w: Int32
    var h: Int32



struct SDL_PixelFormat:
    pass



struct SDL_Renderer:
    pass



struct SDL_Texture:
    pass



struct SDL_Surface:
    var flags: UInt32
    var format: CPtr[SDL_PixelFormat]
    var w: Int32
    var h: Int32
    var pitch: Int32
    var pixels: CPtr[UInt32]
    var userdata: CPtr[Int8]
    var locked: Int32
    var list_blitmap: CPtr[Int8]
    var clip_rect: SDL_Rect
    var map: CPtr[Int8]
    var refcount: Int32


comptime SDL_QUIT = 0x100

comptime SDL_KEYDOWN = 0x300
comptime SDL_KEYUP = 0x301

comptime SDL_MOUSEMOTION = 0x400
comptime SDL_MOUSEBUTTONDOWN = 0x401
comptime SDL_MOUSEBUTTONUP = 0x402
comptime SDL_MOUSEWHEEL = 0x403



struct Keysym:
    var scancode: Int32
    var keycode: Int32
    var mod: UInt16
    var unused: UInt32

    fn __init__(mut self):
        self.scancode = 0
        self.keycode = 0
        self.mod = 0
        self.unused = 0



struct MouseMotionEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var state: UInt32
    var x: Int32
    var y: Int32
    var xrel: Int32
    var yrel: Int32



struct MouseButtonEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var button: UInt8
    var state: UInt8
    var clicks: UInt8
    var padding1: UInt8
    var x: Int32
    var y: Int32



struct MouseWheelEvent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var which: UInt32
    var x: Int32
    var y: Int32
    var direction: UInt32
    var preciseX: Float32
    var preciseY: Float32
    var mouseX: Int32
    var mouseY: Int32



struct Keyevent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var state: UInt8
    var repeat: UInt8
    var padding2: UInt8
    var padding3: UInt8
    var keysym: Keysym

    def __init__(mut self):
        self.type = 0
        self.timestamp = 0
        self.windowID = 0
        self.state = 0
        self.repeat = 0
        self.padding2 = 0
        self.padding3 = 0
        self.keysym = Keysym()



struct Event:
    var type: UInt32
    var _padding: SIMD[DType.uint8, 16]
    var _padding2: Int64
    var _padding3: Int64

    fn __init__(mut self):
        self.type = 0
        self._padding = 0
        self._padding2 = 0
        self._padding3 = 0

    def as_keyboard(mut self) -> CPtr[Keyevent]:
        return UnsafePointer.address_of(self).bitcast[Keyevent]()

    def as_mousemotion(mut self) -> CPtr[MouseMotionEvent]:
        return UnsafePointer.address_of(self).bitcast[MouseMotionEvent]()

    def as_mousebutton(mut self) -> CPtr[MouseButtonEvent]:
        return UnsafePointer.address_of(self).bitcast[MouseButtonEvent]()

    def as_mousewheel(mut self) -> CPtr[MouseWheelEvent]:
        return UnsafePointer.address_of(self).bitcast[MouseWheelEvent]()


# SDL.h
comptime c_SDL_Init = fn (w: Int32) -> Int32
comptime c_SDL_Quit = fn () -> None

# SDL_stdinc.h
# SDL_error.h
# SDL_video.h
comptime c_SDL_CreateWindow = fn (
    CPtrRO[UInt8], Int32, Int32, Int32, Int32, Int32
) -> CPtr[SDL_Window]
comptime c_SDL_DestroyWindow = fn (CPtr[SDL_Window]) -> None
comptime c_SDL_GetWindowSurface = fn (s: CPtr[SDL_Window]) -> CPtr[
    SDL_Surface
]
comptime c_SDL_UpdateWindowSurface = fn (s: CPtr[SDL_Window]) -> Int32

# SDL_pixels.h
comptime c_SDL_MapRGB = fn (Int32, Int32, Int32, Int32) -> UInt32

# SDL_timer.h
comptime c_SDL_Delay = fn (Int32) -> UInt32

# SDL_event.h
comptime c_SDL_PollEvent = fn (CPtr[Event]) -> Int32

# SDL_render.h
comptime c_SDL_CreateRenderer = fn (
    CPtr[SDL_Window], Int32, UInt32
) -> CPtr[SDL_Renderer]
comptime c_SDL_DestroyRenderer = fn (CPtr[SDL_Renderer]) -> None

comptime c_SDL_CreateWindowAndRenderer = fn (
    Int32,
    Int32,
    UInt32,
    CPtr[CPtr[Int8]],
    CPtr[CPtr[SDL_Renderer]],
) -> Int32
comptime c_SDL_RenderDrawPoint = fn (
    CPtr[SDL_Renderer], Int32, Int32
) -> Int32
comptime c_SDL_RenderDrawRect = fn (
    r: CPtr[SDL_Renderer], rect: CPtr[SDL_Rect]
) -> Int32
comptime c_SDL_RenderPresent = fn (s: CPtr[SDL_Renderer]) -> Int32
comptime c_SDL_RenderClear = fn (s: CPtr[SDL_Renderer]) -> Int32
comptime c_SDL_SetRenderDrawColor = fn (
    CPtr[SDL_Renderer], UInt8, UInt8, UInt8, UInt8
) -> Int32
comptime SDL_BlendMode = Int
comptime c_SDL_SetRenderDrawBlendMode = fn (
    CPtr[SDL_Renderer], SDL_BlendMode
) -> Int32
comptime c_SDL_SetRenderTarget = fn (
    r: CPtr[SDL_Renderer],
    # t: CPtr[SDL_Texture]) -> Int32
    t: Int64,
) -> Int32

comptime c_SDL_RenderCopy = fn (
    r: CPtr[SDL_Renderer],
    t: CPtr[SDL_Texture],
    s: Int64,
    d: Int64,
) -> Int32

# SDL_surface.h
comptime c_SDL_FillRect = fn (CPtr[SDL_Surface], Int64, UInt32) -> Int32


# texture
comptime c_SDL_CreateTexture = fn (
    CPtr[SDL_Renderer], UInt32, Int32, Int32, Int32
) -> CPtr[SDL_Texture]
comptime c_SDL_DestroyTexture = fn (CPtr[SDL_Texture]) -> None
comptime c_SDL_LockTexture = fn (
    CPtr[SDL_Texture],
    CPtr[SDL_Rect],
    mut CPtr[
        SIMD[DType.uint8, 1]
    ],  # Pixel data
    mut CPtr[
        Int32
    ],  # Pitch
) -> Int32
comptime c_SDL_UnlockTexture = fn (CPtr[SDL_Texture]) -> None


comptime SDL_WINDOWPOS_UNDEFINED = 0x1FFF0000
comptime SDL_WINDOWPOS_CENTERED = 0x2FFF0000
comptime SDL_WINDOW_SHOWN = 0x00000004

# SDL_error.h
comptime c_SDL_GetError = fn () -> CPtr[UInt8]


struct SDL:
    var _handle: OwnedDLHandle
    var Init: c_SDL_Init
    var Quit: c_SDL_Quit

    var CreateWindow: c_SDL_CreateWindow
    var DestroyWindow: c_SDL_DestroyWindow

    var GetWindowSurface: c_SDL_GetWindowSurface
    var UpdateWindowSurface: c_SDL_UpdateWindowSurface
    var CreateRenderer: c_SDL_CreateRenderer
    var DestroyRenderer: c_SDL_DestroyRenderer
    var CreateWindowAndRenderer: c_SDL_CreateWindowAndRenderer
    var RenderDrawPoint: c_SDL_RenderDrawPoint
    var RenderDrawRect: c_SDL_RenderDrawRect
    var SetRenderDrawColor: c_SDL_SetRenderDrawColor
    var RenderPresent: c_SDL_RenderPresent
    var RenderClear: c_SDL_RenderClear
    var CreateTexture: c_SDL_CreateTexture
    var DestroyTexture: c_SDL_DestroyTexture

    var LockTexture: c_SDL_LockTexture
    var UnlockTexture: c_SDL_UnlockTexture
    var SetRenderDrawBlendMode: c_SDL_SetRenderDrawBlendMode
    var SetRenderTarget: c_SDL_SetRenderTarget
    var RenderCopy: c_SDL_RenderCopy

    var MapRGB: c_SDL_MapRGB
    var FillRect: c_SDL_FillRect
    var Delay: c_SDL_Delay
    var PollEvent: c_SDL_PollEvent

    var GetError: c_SDL_GetError

    fn __init__(out self) raises:
        var lib_path = get_sdl_lib_path()
        self._handle = OwnedDLHandle(lib_path)

        self.Init = self._handle.get_function[c_SDL_Init]("SDL_Init")
        self.Quit = self._handle.get_function[c_SDL_Quit]("SDL_Quit")

        self.CreateWindow = self._handle.get_function[c_SDL_CreateWindow](
            "SDL_CreateWindow"
        )
        self.DestroyWindow = self._handle.get_function[c_SDL_DestroyWindow](
            "SDL_DestroyWindow"
        )

        self.GetWindowSurface = self._handle.get_function[c_SDL_GetWindowSurface](
            "SDL_GetWindowSurface"
        )
        self.UpdateWindowSurface = self._handle.get_function[c_SDL_UpdateWindowSurface](
            "SDL_UpdateWindowSurface"
        )

        self.CreateRenderer = self._handle.get_function[c_SDL_CreateRenderer](
            "SDL_CreateRenderer"
        )
        self.DestroyRenderer = self._handle.get_function[c_SDL_DestroyRenderer](
            "SDL_DestroyRenderer"
        )
        self.CreateWindowAndRenderer = self._handle.get_function[
            c_SDL_CreateWindowAndRenderer
        ]("SDL_CreateWindowAndRenderer")
        self.RenderDrawPoint = self._handle.get_function[c_SDL_RenderDrawPoint](
            "SDL_RenderDrawPoint"
        )
        self.RenderDrawRect = self._handle.get_function[c_SDL_RenderDrawRect](
            "SDL_RenderDrawRect"
        )
        self.SetRenderDrawColor = self._handle.get_function[c_SDL_SetRenderDrawColor](
            "SDL_SetRenderDrawColor"
        )
        self.RenderPresent = self._handle.get_function[c_SDL_RenderPresent](
            "SDL_RenderPresent"
        )
        self.RenderClear = self._handle.get_function[c_SDL_RenderClear](
            "SDL_RenderClear"
        )
        self.SetRenderDrawBlendMode = self._handle.get_function[
            c_SDL_SetRenderDrawBlendMode
        ]("SDL_SetRenderDrawBlendMode")
        self.SetRenderTarget = self._handle.get_function[c_SDL_SetRenderTarget](
            "SDL_SetRenderTarget"
        )
        self.RenderCopy = self._handle.get_function[c_SDL_RenderCopy]("SDL_RenderCopy")

        self.CreateTexture = self._handle.get_function[c_SDL_CreateTexture](
            "SDL_CreateTexture"
        )
        self.DestroyTexture = self._handle.get_function[c_SDL_DestroyTexture](
            "SDL_DestroyTexture"
        )
        self.LockTexture = self._handle.get_function[c_SDL_LockTexture](
            "SDL_LockTexture"
        )
        self.UnlockTexture = self._handle.get_function[c_SDL_UnlockTexture](
            "SDL_UnlockTexture"
        )

        self.MapRGB = self._handle.get_function[c_SDL_MapRGB]("SDL_MapRGB")
        self.FillRect = self._handle.get_function[c_SDL_FillRect]("SDL_FillRect")
        self.Delay = self._handle.get_function[c_SDL_Delay]("SDL_Delay")
        self.PollEvent = self._handle.get_function[c_SDL_PollEvent]("SDL_PollEvent")

        self.GetError = self._handle.get_function[c_SDL_GetError]("SDL_GetError")

    fn get_sdl_error_as_string(self) -> String:
        var error_ptr = self.GetError()  # Call the function to get the error pointer

        if error_ptr == UnsafePointer[UInt8]():  # Check if the pointer is null
            return "Unknown error"

        var error_string = String(error_ptr[])
        return error_string
