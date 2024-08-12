# mo3d
Prototype 3d library for [mojo](https://docs.modular.com/mojo/manual/)
- [x] Cross platform SDL window with [`ffi`](https://docs.modular.com/mojo/stdlib/sys/ffi/) bindings directly to `mojo` (based on [mojo-sdl](https://github.com/msteele/mojo-sdl/))
- [ ] Basic `3D` primitives and behaviours (vectors/rays with dot/cross products etc.)
- [ ] Basic shader replacement pattern (however no need to use actual graphics shaders - as the idea is that mojo optimized compute can perform the same function directly)
- [ ] Mesh rendering (using bvh or other similar acceleration structure)
- [ ] ...

## attribution and inspiration
- [mojo-sdl](https://github.com/msteele/mojo-sdl/)
- [magnum-graphics](https://magnum.graphics/)
- [bevy](https://bevyengine.org/)
- [ray tracing in weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html)

## dev
- devcontainer or mac
- `make setup-linux-env` or `make setup-mac-env`
- `make run`
- `make ...` # See `Makefile`

## progess notes
### 2024-08-11: hello window
- Basic window rendering on linux (within vscode devcontainer on windows) and mac
- Basic kernal, however, need to refine the vectorised worker code that sets the pixel stage (tensor `t`)

![image](https://github.com/user-attachments/assets/13f3c360-2ba6-441a-aebf-ed7507e45c3b)
