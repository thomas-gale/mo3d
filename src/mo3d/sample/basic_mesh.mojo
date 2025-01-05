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
](inout store: ComponentStore[T, 3]) raises:
    """
    The classic end scene from the Ray Tracing in One Weekend by Peter Shirley.
    """
    alias dim = 3

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

    # # Make a triangle
    # var tex1 = Texture[T, dim](Solid[T, dim](Color4[T](0.2, 0.8, 0.3)))
    # var mat1 = Material[T, dim](
    #      Lambertian[T, dim](tex1)
    # )
    # var tri1 = Triangle[T](
    #     Point[T, dim](-4, 1, 0),
    #     Point[T, dim](0, 1, 0),
    #     Point[T, dim](0, 0, 0)
    #     )
    # var tri1_entity_id = store.create_entity()
    # _ = store.add_components(
    #     tri1_entity_id,
    #     Point[T, dim](0, 0, 0),
    #     Geometry[T, dim](tri1),
    #     mat1,
    # )

    # # Add tiny spheres on the vertices
    # var tex_vert = Texture[T, dim](Solid[T, dim](Color4[T](0.8, 0.2, 0.2)))
    # var mat_vert = Material[T, dim](
    #      Lambertian[T, dim](tex_vert)
    # )
    # var verts = List(Point[T, dim](-4, 1, 0),
    #     Point[T, dim](0, 1, 0),
    #     Point[T, dim](0, 0, 0))
    # var sphere = Sphere[T, dim](0.1)
    # for p in verts:
    #     _ = store.add_components(
    #         store.create_entity(),
    #         p[],
    #         Geometry[T, dim](sphere),
    #         mat_vert,
    #     )


    var tex_mesh = Texture[T, dim](Solid[T, dim](Color4[T](0.8, 0.2, 0.2)))
    var mat_mesh = Material[T, dim](
         Lambertian[T, dim](tex_mesh)
    )
    # Load a mesh
    var mesh = Mesh[T].load_from_binary_stl("data/Utah_teapot_(solid).stl")
    #var mesh = Mesh[T].load_from_binary_stl("data/cube.stl")
    _ = store.add_components(
        store.create_entity(),
        Point[T, dim](0,0,0),
        Geometry[T, dim](mesh),
        mat_mesh,
    )