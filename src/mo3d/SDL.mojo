# Attribution: https://github.com/msteele/mojo-sdl/tree/main
# WIP: Upgrading for mojo 24.4.0

from sys import ffi, info

fn get_sdl_lib_path() -> StringLiteral:
    if (info.os_is_linux()):
        var lib_path = '/usr/lib/x86_64-linux-gnu/libSDL2.so'
        try:
            with open('/etc/os-release', 'r') as f:
                var release = f.read()
                if (release.find('Ubuntu') < 0):
                    lib_path = '/usr/lib64/libSDL2.so'
        except:
            print("Can't detect Linux version")
        return lib_path
    if (info.os_is_macos()):
        return '/opt/homebrew/lib/libSDL2.dylib'
    return ""

#    SDL_PIXELFORMAT_RGBA8888 =
#      SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA,
#                             SDL_PACKEDLAYOUT_8888, 32, 4),

alias SDL_PIXELTYPE_PACKED32 = 6
alias SDL_PACKEDORDER_RGBA = 4
alias SDL_PACKEDLAYOUT_8888 = 6


fn SDL_DEFINE_PIXELFORMAT(type: Int, order: Int, layout: Int, bits: Int, bytes: Int) -> Int:
    return ((1 << 28) | ((type) << 24) | ((order) << 20) | ((layout) << 16) | ((bits) << 8) | ((bytes) << 0))

alias SDL_PIXELFORMAT_RGBA8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32,
                                                        SDL_PACKEDORDER_RGBA,
                                                        SDL_PACKEDLAYOUT_8888,
                                                        32,
                                                        4)

alias SDL_TEXTUREACCESS_TARGET = 2




@register_passable('trivial')
struct SDL_Window:
    pass

@register_passable('trivial')
struct SDL_Rect:
    var x: Int32
    var y: Int32
    var w: Int32
    var h: Int32

@register_passable('trivial')
struct SDL_PixelFormat:
    pass

@register_passable('trivial')
struct SDL_Renderer:
    pass

@register_passable('trivial')
struct SDL_Texture:
    pass

@register_passable('trivial')
struct SDL_Surface:
    var flags: UInt32
    var format: Pointer[SDL_PixelFormat]
    var w: Int32
    var h: Int32
    var pitch: Int32
    var pixels: Pointer[UInt32]
    var userdata: Pointer[Int8]
    var locked: Int32
    var list_blitmap: Pointer[Int8]
    var clip_rect: SDL_Rect
    var map: Pointer[Int8]
    var refcount: Int32



alias SDL_QUIT = 0x100

alias SDL_KEYDOWN = 0x300
alias SDL_KEYUP   = 0x301
#alias SDL_

alias SDL_MOUSEMOTION     = 0x400
alias SDL_MOUSEBUTTONDOWN = 0x401
alias SDL_MOUSEBUTTONUP   = 0x402
alias SDL_MOUSEWHEEL      = 0x403

@register_passable('trivial')
struct Keysym:
    var scancode: Int32
    var keycode: Int32
    var mod: UInt16
    var unused: UInt32

@register_passable('trivial')
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

@register_passable('trivial')
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

@register_passable('trivial')
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

@register_passable('trivial')
struct Event:
    var type: Int32
    var _padding: SIMD[DType.uint8, 16]
    var _padding2: Int64
    var _padding3: Int64
    # def __init__(inout self) -> Event:
    #     return Event { type: 0, _padding: 0, _padding2: 0, _padding3: 0 }

    fn __init__(inout self):
       self.type = 0
       self._padding = 0
       self._padding2 = 0
       self._padding3 = 0

    def as_keyboard(self) -> Keyevent:
        return Pointer.address_of(self).bitcast[Keyevent]().load()

    def as_mousemotion(self) -> MouseMotionEvent:
        return Pointer.address_of(self).bitcast[MouseMotionEvent]().load()

    def as_mousebutton(self) -> MouseButtonEvent:
        return Pointer.address_of(self).bitcast[MouseButtonEvent]().load()

    def as_mousewheel(self) -> MouseWheelEvent:
        return Pointer.address_of(self).bitcast[MouseWheelEvent]().load()


#alias Event = Keyevent

@register_passable('trivial')
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
        #self.value = 0
        self.timestamp = 0
        self.windowID = 0
        self.state = 0
        self.repeat = 0
        self.padding2 = 0
        self.padding3 = 0


# SDL.h
alias c_SDL_Init = fn(w: Int32) -> Int32
alias c_SDL_Quit = fn() -> None

# SDL_video.h
alias c_SDL_CreateWindow = fn(DTypePointer[DType.uint8], Int32, Int32, Int32, Int32, Int32) -> Pointer[SDL_Window]
alias c_SDL_DestroyWindow = fn(Pointer[SDL_Window]) -> None
alias c_SDL_GetWindowSurface = fn(Pointer[Int8]) -> Pointer[SDL_Surface]
alias c_SDL_UpdateWindowSurface = fn(Pointer[Int8]) -> Int32

# SDL_pixels.h
alias c_SDL_MapRGB = fn(Int32, Int32, Int32, Int32) -> UInt32

# SDL_timer.h
alias c_SDL_Delay = fn(Int32) -> UInt32

# SDL_event.h
alias c_SDL_PollEvent = fn(Pointer[Event]) -> Int32

# SDL_render.h
alias c_SDL_CreateRenderer = fn(Pointer[SDL_Window], Int32, UInt32) -> Pointer[SDL_Renderer]
alias c_SDL_CreateWindowAndRenderer = fn(Int32, Int32, UInt32, Pointer[Pointer[Int8]], Pointer[Pointer[SDL_Renderer]]) -> Int32
alias c_SDL_RenderDrawPoint = fn(Pointer[SDL_Renderer], Int32, Int32) -> Int32
alias c_SDL_RenderDrawRect = fn(r: Pointer[SDL_Renderer], rect: Pointer[SDL_Rect]) -> Int32
alias c_SDL_RenderPresent = fn(s: Pointer[SDL_Renderer]) -> Int32
alias c_SDL_RenderClear = fn(s: Pointer[SDL_Renderer]) -> Int32
alias c_SDL_SetRenderDrawColor = fn(Pointer[SDL_Renderer], UInt8, UInt8, UInt8, UInt8) -> Int32
alias SDL_BlendMode = Int
alias c_SDL_SetRenderDrawBlendMode = fn(Pointer[SDL_Renderer], SDL_BlendMode) -> Int32
alias c_SDL_SetRenderTarget = fn(r: Pointer[SDL_Renderer],
#                                 t: Pointer[SDL_Texture]) -> Int32
                                 t: Int64) -> Int32

alias c_SDL_RenderCopy = fn(r: Pointer[SDL_Renderer],
                            t: Int64,  #t: Pointer[SDL_Texture],
                            s: Int64, d: Int64) -> Int32
                            #s: Pointer[SDL_Rect], d: Pointer[SDL_Rect]) -> Int32

# SDL_surface.h
alias c_SDL_FillRect = fn(Pointer[SDL_Surface], Int64, UInt32) -> Int32


# texture
alias c_SDL_CreateTexture = fn(Pointer[SDL_Renderer],
                               UInt32, Int32,
                               Int32, Int32) -> Int64 #Pointer[SDL_Texture]



alias SDL_WINDOWPOS_UNDEFINED = 0x1FFF0000

alias SDL_WINDOW_SHOWN = 0x00000004


struct SDL:
    var Init: c_SDL_Init
    var Quit: c_SDL_Quit

    var CreateWindow: c_SDL_CreateWindow
    var DestroyWindow: c_SDL_DestroyWindow

    var GetWindowSurface: c_SDL_GetWindowSurface
    var UpdateWindowSurface: c_SDL_UpdateWindowSurface
    var CreateRenderer: c_SDL_CreateRenderer
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
        print("binding SDL")
        var lib_path = get_sdl_lib_path()
        #let SDL = ffi.DLHandle('/usr/lib64/libSDL2.so')
        var SDL = ffi.DLHandle(lib_path)

        self.Init = SDL.get_function[c_SDL_Init]('SDL_Init')
        self.Quit = SDL.get_function[c_SDL_Quit]('SDL_Quit')

        self.CreateWindow = SDL.get_function[c_SDL_CreateWindow]('SDL_CreateWindow')
        self.DestroyWindow = SDL.get_function[c_SDL_DestroyWindow]('SDL_DestroyWindow')

        self.GetWindowSurface = SDL.get_function[c_SDL_GetWindowSurface]('SDL_GetWindowSurface')
        self.UpdateWindowSurface = SDL.get_function[c_SDL_UpdateWindowSurface]('SDL_UpdateWindowSurface')

        self.CreateRenderer = SDL.get_function[c_SDL_CreateRenderer]('SDL_CreateRenderer')
        self.CreateWindowAndRenderer = SDL.get_function[c_SDL_CreateWindowAndRenderer]('SDL_CreateWindowAndRenderer')
        self.RenderDrawPoint = SDL.get_function[c_SDL_RenderDrawPoint]('SDL_RenderDrawPoint')
        self.RenderDrawRect = SDL.get_function[c_SDL_RenderDrawRect]('SDL_RenderDrawRect')
        self.SetRenderDrawColor = SDL.get_function[c_SDL_SetRenderDrawColor]('SDL_SetRenderDrawColor')
        self.RenderPresent = SDL.get_function[c_SDL_RenderPresent]('SDL_RenderPresent')
        self.RenderClear = SDL.get_function[c_SDL_RenderClear]('SDL_RenderClear')
        self.SetRenderDrawBlendMode = SDL.get_function[c_SDL_SetRenderDrawBlendMode]('SDL_SetRenderDrawBlendMode')
        self.SetRenderTarget = SDL.get_function[c_SDL_SetRenderTarget]('SDL_SetRenderTarget')
        self.RenderCopy = SDL.get_function[c_SDL_RenderCopy]('SDL_RenderCopy')

        self.CreateTexture = SDL.get_function[c_SDL_CreateTexture]('SDL_CreateTexture')


        self.MapRGB = SDL.get_function[c_SDL_MapRGB]('SDL_MapRGB')
        self.FillRect = SDL.get_function[c_SDL_FillRect]('SDL_FillRect')
        self.Delay = SDL.get_function[c_SDL_Delay]('SDL_Delay')
        self.PollEvent = SDL.get_function[c_SDL_PollEvent]('SDL_PollEvent')