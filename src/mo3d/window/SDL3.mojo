from memory import UnsafePointer
from sys import ffi, info


fn get_sdl_lib_path() -> StringLiteral:
    if info.os_is_linux():
        return "/usr/local/lib/libSDL3.so"
    if info.os_is_macos():
        return "TODO"
    return ""


alias SDL_PIXELTYPE_PACKED32 = 6
alias SDL_PACKEDORDER_RGBA = 4
alias SDL_PACKEDLAYOUT_8888 = 6


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


alias SDL_PIXELFORMAT_RGBA8888 = SDL_DEFINE_PIXELFORMAT(
    SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4
)

alias SDL_TEXTUREACCESS_TARGET = 2
alias SDL_INIT_VIDEO = 0x00000020


@register_passable("trivial")
struct SDL_Window:
    pass


@register_passable("trivial")
struct SDL_Rect:
    var x: Int32
    var y: Int32
    var w: Int32
    var h: Int32


@register_passable("trivial")
struct SDL_PixelFormat:
    pass


@register_passable("trivial")
struct SDL_Renderer:
    pass


@register_passable("trivial")
struct SDL_Texture:
    pass


@register_passable("trivial")
struct SDL_Surface:
    var flags: UInt32
    var format: UnsafePointer[SDL_PixelFormat]
    var w: Int32
    var h: Int32
    var pitch: Int32
    var pixels: UnsafePointer[UInt32]
    var userdata: UnsafePointer[Int8]
    var locked: Int32
    var list_blitmap: UnsafePointer[Int8]
    var clip_rect: SDL_Rect
    var map: UnsafePointer[Int8]
    var refcount: Int32


alias SDL_QUIT = 0x100

alias SDL_KEYDOWN = 0x300
alias SDL_KEYUP = 0x301

alias SDL_MOUSEMOTION = 0x400
alias SDL_MOUSEBUTTONDOWN = 0x401
alias SDL_MOUSEBUTTONUP = 0x402
alias SDL_MOUSEWHEEL = 0x403


@register_passable("trivial")
struct Keysym:
    var scancode: Int32
    var keycode: Int32
    var mod: UInt16
    var unused: UInt32

    fn __init__(inout self):
        self.scancode = 0
        self.keycode = 0
        self.mod = 0
        self.unused = 0


@register_passable("trivial")
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


@register_passable("trivial")
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


@register_passable("trivial")
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

@register_passable("trivial")
struct Event:
    var type: UInt32
    var padding: SIMD[DType.uint8, 128]

    fn __init__(inout self):
        self.type = 0
        self.padding = 0


# @register_passable("trivial")
# struct Event:
#     var type: Int32
#     var _padding: SIMD[DType.uint8, 16]
#     var _padding2: Int64
#     var _padding3: Int64
#     # def __init__(inout self) -> Event:
#     #     return Event { type: 0, _padding: 0, _padding2: 0, _padding3: 0 }

#     fn __init__(inout self):
#         self.type = 0
#         self._padding = 0
#         self._padding2 = 0
#         self._padding3 = 0

    # def as_keyboard(self: Self) -> Keyevent:
    #     return UnsafePointer.address_of(Reference[Self, True, MutableStaticLifetime](self)).bitcast[Keyevent]().load()

    # def as_mousemotion(self) -> MouseMotionEvent:
    #     return UnsafePointer.address_of(self).bitcast[MouseMotionEvent]().load()

    # def as_mousebutton(self) -> MouseButtonEvent:
    #     return UnsafePointer.address_of(self).bitcast[MouseButtonEvent]().load()

    # def as_mousewheel(self) -> MouseWheelEvent:
    #     return UnsafePointer.address_of(self).bitcast[MouseWheelEvent]().load()


@register_passable("trivial")
struct Keyevent:
    var type: UInt32
    var timestamp: UInt32
    var windowID: UInt32
    var state: UInt8
    var repeat: UInt8
    var padding2: UInt8
    var padding3: UInt8
    var keysym: Keysym

    def __init__(inout self):
        self.type = 0
        self.timestamp = 0
        self.windowID = 0
        self.state = 0
        self.repeat = 0
        self.padding2 = 0
        self.padding3 = 0
        self.keysym = Keysym()


# SDL.h
alias c_SDL_Init = fn (w: Int32) -> Int32
alias c_SDL_Quit = fn () -> None

# SDL_video.h
alias c_SDL_CreateWindow = fn (
    UnsafePointer[UInt8], Int32, Int32, Int32
) -> UnsafePointer[SDL_Window]
alias c_SDL_DestroyWindow = fn (UnsafePointer[SDL_Window]) -> None
alias c_SDL_GetWindowSurface = fn (s: UnsafePointer[Int8]) -> UnsafePointer[
    SDL_Surface
]
alias c_SDL_UpdateWindowSurface = fn (s: UnsafePointer[Int8]) -> Int32

# SDL_pixels.h
alias c_SDL_MapRGB = fn (Int32, Int32, Int32, Int32) -> UInt32

# SDL_timer.h
alias c_SDL_Delay = fn (Int32) -> UInt32

# SDL_events.h
alias c_SDL_PollEvent = fn (UnsafePointer[Event]) -> Int32

# SDL_render.h
alias c_SDL_CreateRenderer = fn (
    UnsafePointer[SDL_Window], Int32
) -> UnsafePointer[SDL_Renderer]
alias c_SDL_DestroyRenderer = fn (UnsafePointer[SDL_Renderer]) -> None

alias c_SDL_CreateWindowAndRenderer = fn (
    Int32,
    Int32,
    UInt32,
    UnsafePointer[UnsafePointer[Int8]],
    UnsafePointer[UnsafePointer[SDL_Renderer]],
) -> Int32
alias c_SDL_RenderDrawPoint = fn (
    UnsafePointer[SDL_Renderer], Int32, Int32
) -> Int32
alias c_SDL_RenderDrawRect = fn (
    r: UnsafePointer[SDL_Renderer], rect: UnsafePointer[SDL_Rect]
) -> Int32
alias c_SDL_RenderPresent = fn (s: UnsafePointer[SDL_Renderer]) -> Int32
alias c_SDL_RenderClear = fn (s: UnsafePointer[SDL_Renderer]) -> Int32
alias c_SDL_SetRenderDrawColor = fn (
    UnsafePointer[SDL_Renderer], UInt8, UInt8, UInt8, UInt8
) -> Int32
alias SDL_BlendMode = Int
alias c_SDL_SetRenderDrawBlendMode = fn (
    UnsafePointer[SDL_Renderer], SDL_BlendMode
) -> Int32
alias c_SDL_SetRenderTarget = fn (
    r: UnsafePointer[SDL_Renderer],
    # t: UnsafePointer[SDL_Texture]) -> Int32
    t: Int64,
) -> Int32

alias c_SDL_RenderCopy = fn (
    r: UnsafePointer[SDL_Renderer],
    t: Int64,  # t: UnsafePointer[SDL_Texture],
    s: Int64,
    d: Int64,
) -> Int32

# SDL_surface.h
alias c_SDL_FillRect = fn (UnsafePointer[SDL_Surface], Int64, UInt32) -> Int32


# texture
alias c_SDL_CreateTexture = fn (
    UnsafePointer[SDL_Renderer], UInt32, Int32, Int32, Int32
) -> Int64  # UnsafePointer[SDL_Texture]


alias SDL_WINDOWPOS_UNDEFINED = 0x1FFF0000
alias SDL_WINDOWPOS_CENTERED = 0x2FFF0000
alias SDL_WINDOW_SHOWN = 0x00000004


struct SDL:
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
    var SetRenderDrawBlendMode: c_SDL_SetRenderDrawBlendMode
    var SetRenderTarget: c_SDL_SetRenderTarget
    var RenderCopy: c_SDL_RenderCopy

    var MapRGB: c_SDL_MapRGB
    var FillRect: c_SDL_FillRect
    var Delay: c_SDL_Delay
    var PollEvent: c_SDL_PollEvent

    fn __init__(inout self):
        print("Loading SDL3...")
        var lib_path = get_sdl_lib_path()
        var SDL = ffi.DLHandle(lib_path)

        self.Init = SDL.get_function[c_SDL_Init]("SDL_Init")
        self.Quit = SDL.get_function[c_SDL_Quit]("SDL_Quit")

        self.CreateWindow = SDL.get_function[c_SDL_CreateWindow](
            "SDL_CreateWindow"
        )
        self.DestroyWindow = SDL.get_function[c_SDL_DestroyWindow](
            "SDL_DestroyWindow"
        )

        self.GetWindowSurface = SDL.get_function[c_SDL_GetWindowSurface](
            "SDL_GetWindowSurface"
        )
        self.UpdateWindowSurface = SDL.get_function[c_SDL_UpdateWindowSurface](
            "SDL_UpdateWindowSurface"
        )

        self.CreateRenderer = SDL.get_function[c_SDL_CreateRenderer](
            "SDL_CreateRenderer"
        )
        self.DestroyRenderer = SDL.get_function[c_SDL_DestroyRenderer](
            "SDL_DestroyRenderer"
        )

        self.CreateWindowAndRenderer = SDL.get_function[
            c_SDL_CreateWindowAndRenderer
        ]("SDL_CreateWindowAndRenderer")
        self.RenderDrawPoint = SDL.get_function[c_SDL_RenderDrawPoint](
            "SDL_RenderDrawPoint"
        )
        self.RenderDrawRect = SDL.get_function[c_SDL_RenderDrawRect](
            "SDL_RenderDrawRect"
        )
        self.SetRenderDrawColor = SDL.get_function[c_SDL_SetRenderDrawColor](
            "SDL_SetRenderDrawColor"
        )
        self.RenderPresent = SDL.get_function[c_SDL_RenderPresent](
            "SDL_RenderPresent"
        )
        self.RenderClear = SDL.get_function[c_SDL_RenderClear](
            "SDL_RenderClear"
        )
        self.SetRenderDrawBlendMode = SDL.get_function[
            c_SDL_SetRenderDrawBlendMode
        ]("SDL_SetRenderDrawBlendMode")
        self.SetRenderTarget = SDL.get_function[c_SDL_SetRenderTarget](
            "SDL_SetRenderTarget"
        )
        self.RenderCopy = SDL.get_function[c_SDL_RenderCopy]("SDL_RenderCopy")

        self.CreateTexture = SDL.get_function[c_SDL_CreateTexture](
            "SDL_CreateTexture"
        )

        self.MapRGB = SDL.get_function[c_SDL_MapRGB]("SDL_MapRGB")
        self.FillRect = SDL.get_function[c_SDL_FillRect]("SDL_FillRect")
        self.Delay = SDL.get_function[c_SDL_Delay]("SDL_Delay")
        self.PollEvent = SDL.get_function[c_SDL_PollEvent]("SDL_PollEvent")

        print("Loaded SDL3!")
