from mo3d.ecs.component_store import ComponentStore
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.color4 import Color4
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.sphere import Sphere
from mo3d.geometry.triangle import Triangle
from mo3d.geometry.mesh import Mesh
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.texture.texture import Texture
from mo3d.texture.solid import Solid



fn basic_mesh_scene_3d[
    T: DType
](mut store: ComponentStore[T, 3]) raises:
    """
    A scene with a loaded mesh and a ground plane.
    """
    comptime dim = 3

    # Ground
    var tex_ground = Texture[T, dim](
        Solid[T, dim](Color4[T](0.5, 0.5, 0.5))
    )
    var mat_ground = Material[T, dim](
        Lambertian[T, dim](tex_ground)
    )
    var ground = Sphere[T, dim](1000)
    var ground_entity_id = store.create_entity()
    _ = store.add_components(
        ground_entity_id,
        Point[T, dim](0, -1000, 0),
        Geometry[T, dim](ground),
        mat_ground,
    )

    var tex_mesh = Texture[T, dim](Solid[T, dim](Color4[T](0.8, 0.2, 0.2)))
    var mat_mesh = Material[T, dim](
         Lambertian[T, dim](tex_mesh)
    )
    # Load a mesh
    var mesh = Mesh[T].load_from_binary_stl("data/Utah_teapot_(solid).stl", 0.1)
    print("Loaded: " + String(mesh))
    _ = store.add_components(
        store.create_entity(),
        Point[T, dim](0,0,0),
        Geometry[T, dim](mesh),
        mat_mesh,
    )