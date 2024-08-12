# mo3d
Prototype 3d library for Mojo Lang.

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
- Need to refine/correct the vectorised worker code that sets the pixel stage (tensor `t`)
![image](https://github.com/user-attachments/assets/4c4815ad-8462-4a32-8b8a-c8aa6c22360c)
