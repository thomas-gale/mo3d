![image](https://github.com/user-attachments/assets/39e934ae-1aeb-434a-af8f-5986b348e1cc) 
# mo3d
### [mojo](https://docs.modular.com/mojo/manual/) 3D library

> [!WARNING]  
> Under [active](#progress-notes) development/unstable 🔥

- [x] Cross platform SDL window with [`ffi`](https://docs.modular.com/mojo/stdlib/sys/ffi/) bindings directly to `mojo` (based on [mojo-sdl](https://github.com/msteele/mojo-sdl/))
- [x] Basic `3D` primitives and behaviors (vectors/rays with dot/cross products etc.)
- [ ] Basic ray/path tracer based 'ray tracing in one weekend'
	- [x] Antialias
	- [ ] Use Mojo Variant in place of abstract hittables/materials.
- [x] Mouse interaction for arcball orbit controls (e.g. https://asliceofrendering.com/camera/2019/11/30/ArcballCamera/)
- [ ] Basic shader replacement pattern (however no need to use actual graphics shaders - as the idea is that mojo optimized compute can perform the same function directly)
- [ ] Mesh rendering (using bvh or other similar acceleration structure)
- [ ] ...

## attribution and inspiration
- [mojo-sdl](https://github.com/msteele/mojo-sdl/)
- [ray tracing in one weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html)
- [three.js](https://github.com/mrdoob/three.js/)
- [magnum-graphics](https://magnum.graphics/)

## dev
- install [`magic`](https://docs.modular.com/magic/#install-magic)
- see available tasks with `magic run list`
- main app `magic run start`

## progress notes

### 2024-09-09: moving to the magic package manager
- This replaces the `Makefile`
- The environment setup (installing sdl2) is cached based on a proxy of the local `pixi.toml` file - given the stability of `sdl2` API, this should be adequate.
- Other commands should do appropriate caching for extra wonderful speedyness. 

### 2024-08-30: arcball camera implemented and refactoring `vec`/`mat` to be dimensionally parameterized
- Vec4 is now `Vec` - Backing storaged is directly managed via `UnsafePointer`
- Matrix `Mat` - Backing storage is directly managed via `UnsafePointer` (I initially tried owning `dim` number of `Vec`s however, I ended up struggling to convince mojo to not prematurly deallocate them. So instead, now, `Mat` carves out it's own memory and copies to and from `Vec` when required.
- Arcball camera implemenation - many thanks to [this](https://asliceofrendering.com/camera/2019/11/30/ArcballCamera/) article!

https://github.com/user-attachments/assets/480e9b67-529a-4f3b-9a3b-843bfa9760db

### 2024-08-27: refactoring ray, adding hittables, basic ray multi-sampling to update a progressive texture
- Struggling to get a proper generic/runtime polymorphic hittable implementation working.
- Couple of concrete/leaky dependencies in the ray_color/HittableList implementations.
- Added SIMD/generic Interval implementation.
- Added camera implementation.
- Adding basic diffuse lambertian material
- Replaced the Tensor with my own UnsafePointer texture state implementation.
- Progressive rendering to the texture state, so rather than multiple samples in a single pass, the image samples and re-renders, this keeps the frame time at around `10ms` on mac m3.

![image](https://github.com/user-attachments/assets/fab7211a-2841-49f5-9e93-dfcd07fb05d4)

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
- Basic kernel, however, need to refine the vectorized worker code that sets the pixel stage (tensor `t`)

![image](https://github.com/user-attachments/assets/13f3c360-2ba6-441a-aebf-ed7507e45c3b)
