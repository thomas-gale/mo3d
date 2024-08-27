![image](https://github.com/user-attachments/assets/39e934ae-1aeb-434a-af8f-5986b348e1cc) 
# mo3d

> [!WARNING]  
> Under [active](#progress-notes) development/unstable

### graphics library for [mojo](https://docs.modular.com/mojo/manual/)

- [x] Cross platform SDL window with [`ffi`](https://docs.modular.com/mojo/stdlib/sys/ffi/) bindings directly to `mojo` (based on [mojo-sdl](https://github.com/msteele/mojo-sdl/))
- [x] Basic `3D` primitives and behaviours (vectors/rays with dot/cross products etc.)
- [ ] Basic ray/path tracer based 'ray tracing in one weekend'
	- [x] Antialiasing
- [ ] Mouse interaction for orcball orbit controls (e.g. https://asliceofrendering.com/camera/2019/11/30/ArcballCamera/)
- [ ] Basic shader replacement pattern (however no need to use actual graphics shaders - as the idea is that mojo optimized compute can perform the same function directly)
- [ ] Mesh rendering (using bvh or other similar acceleration structure)
- [ ] ...

## attribution and inspiration
- [mojo-sdl](https://github.com/msteele/mojo-sdl/)
- [ray tracing in one weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html)
- [magnum-graphics](https://magnum.graphics/)

## dev
- devcontainer or mac
- `make setup-linux-env` or `make setup-mac-env`
- `make install`
- Set environment variables as documented https://docs.modular.com/max/install depending on terminal
- `make run`
- `make ...` # See `Makefile`

### using nightly version
```
$ mojo --version
mojo 2024.8.2617 (d505bcbe)
$ max --version
max 2024.8.2617 (d505bcbe)
Modular version 2024.8.2617
```

## progress notes

### 2024-08-27: refactoring ray and adding hittables
- Struggling to get a proper generic/runtime polymorhpic hittable implementation working.
- Couple of concrete/leaky dependencies in the ray_colour/HittableList implementations.
- Added SIMD/generic Interval implementation

![image](https://github.com/user-attachments/assets/554cdccb-77a0-47d6-ba3e-74991aa8180a)

### 2024-08-23: wrapping sdl2 in a window trait and battling with over eager resource freeing by mojo
- Took longer that I would have liked to track down the mysterious/non-deterministic corrupted data being rendered in the main loop
- The solution was to signal to mojo that variables captured/referenced within the render kernel should not be deleted till after the main loop
- Finally have the basic ray shooting background from Ray Tracing in One Weekend
- Stats `CPU`:`Ryzen 7 5800X 8-Core` `Window Size`:`800x450` had an average compute time (shoot rays) of `0.80 ms` & average redraw time (copy tensor to gpu texture) of `3.03 ms`

![image](https://github.com/user-attachments/assets/48a30f5f-254f-4ace-bf46-82d7c6a94427)

### 2024-08-22: working directly on the raw texture data from SDL_LockTexture
- Had to remove the SIMD stuff from redrew as we can't be sure of byte alignment of the texture data which is managed memory from SDL2.
- Had to ensure that Mojo didn't attempt to tidy up/mess with the UnsafePointers before SDL_UnlockTexture was called (using `_ = ptr` pattern/hack)
- We have Mojo CPU parallelized (for each row) operations directly on the SDL2 texture data (STREAMING type)
- Parallelized row texture update redraw time down to ~1.5 ms (~4 ms without `parallelized`)
- We can use this approach to quickly move (in the future) a Mojo managed Tensor (hopefully on GPU) which contains our view of the world into SDL2's texture which is being rendered in a window (e.g. in ~1.5ms)

### 2024-08-18: migrated to mojo nightly!

### 2024-08-15: interleaved SIMD tensor
- Using SIMD [interleaving](https://docs.modular.com/mojo/stdlib/builtin/simd/SIMD#interleave) on the 3rd dimension `channels` in (tensor `t`)

![image](https://github.com/user-attachments/assets/88cdf3c8-0241-4cf0-bea5-0015fb4795b7)

### 2024-08-11: hello window
- Basic window rendering on linux (within vscode devcontainer on windows) and mac
- Basic kernal, however, need to refine the vectorised worker code that sets the pixel stage (tensor `t`)

![image](https://github.com/user-attachments/assets/13f3c360-2ba6-441a-aebf-ed7507e45c3b)
