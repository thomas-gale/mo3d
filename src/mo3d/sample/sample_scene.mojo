from memory.arc import ArcPointer
from collections import Optional

from mo3d.ecs.component_store import ComponentStore, ComponentType
from mo3d.math.vec import Vec
from mo3d.math.mat import RotMat
from mo3d.math.point import Point
from mo3d.ray.color4 import Color4
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.sphere import Sphere
from mo3d.geometry.aabb import AABB
from mo3d.material.material import Material
from mo3d.material.lambertian import Lambertian
from mo3d.material.metal import Metal
from mo3d.material.dielectric import Dielectric
from mo3d.material.diffuse_light import DiffuseLight
from mo3d.texture.texture import Texture
from mo3d.texture.solid import Solid
from mo3d.texture.checker import Checker
from mo3d.phys.geometry import PhysGeom, PhysSphere
from mo3d.phys.data import PhysData

from mo3d.random.rng import Rng

fn sample_scene_3d[T: DType](inout store: ComponentStore[T, 3], grid_size: Int = 14) raises:
    """
    The classic end scene from the Ray Tracing in One Weekend by Peter Shirley.
    """
    alias dim = 3

    fn random_float(mut rng : Rng, min: Scalar[T] = 0, max: Scalar[T] = 1.0) -> Scalar[T]:
        return min + (rng.float64().cast[T]() * (max - min))

    # Ground
    var tex_ground_light = Texture[T, dim](
        Solid[T, dim](Color4[T](0.8, 0.8, 0.8))
    )
    var tex_ground_dark = Texture[T, dim](
        Solid[T, dim](Color4[T](0.15, 0.7, 0.15))
    )
    var tex_ground = Texture[T, dim](
        Checker(tex_ground_light, tex_ground_dark, 0.4)
    )
    var mat_ground = Material[T, dim](
        Lambertian[T, dim](tex_ground)
    )
    var ground = Sphere[T, dim](1_000)
    var ground_entity_id = store.create_entity()
    # Add physics for fixed ground plane
    _ = store.add_components(
        ground_entity_id,
        Point[T, dim](0, -1_000, 0),
        Geometry[T, dim](ground),
        mat_ground,
        PhysData[T](PhysGeom[T](PhysSphere[T](ground._radius)), False)
    )

    var rng = Rng(12345)

    # Random primitives
    for a in range(-grid_size, grid_size):
        for b in range(-grid_size, grid_size):
            var choose_mat = random_float(rng)
            var choose_geom = random_float(rng)
            var center = Point[T, dim](
                a + 0.9 * random_float(rng), 0.2, b + 0.9 * random_float(rng)
            )

            if (center - Point[T, dim](4, 0.2, 0)).length() > 0.9:
                var entity_material: Material[T, dim]
                var entity_geometry : Geometry[T,dim]
                var entity_orientation = Optional[RotMat[T, dim]]()
                if choose_geom < 0.8:
                    entity_geometry = Geometry[T,dim](Sphere[T, dim](0.2))
                else:
                    entity_geometry = Geometry[T,dim](
                        AABB[T, dim](Vec[T, dim](-0.2), Vec[T, dim](0.2)))
                    # Add an orientation rotated around y axis
                    var angle = random_float(rng, 0, 3.14)
                    entity_orientation = RotMat.rotate_3(
                        RotMat[T, dim].eye(), angle, Vec[T, dim](0, 1, 0))

                if choose_mat < 0.7:
                    # diffuse
                    var albedo_colour = Color4[T].random(rng) * Color4[T].random(rng)
                    var albedo = Texture[T, dim](
                        Solid[T, dim](albedo_colour)
                    )
                    entity_material = Material[T, dim](
                        Lambertian[T, dim](albedo)
                    )
                elif choose_mat < 0.8:
                    # metal
                    var albedo = Color4[T].random(rng, 0.5, 1)
                    var fuzz = random_float(rng, 0, 0.5)
                    entity_material = Material[T, dim](
                        Metal[T, dim](albedo, fuzz)
                    )
                elif choose_mat < 0.9:
                    # glass
                    entity_material = Material[T, dim](Dielectric[T, dim](1.5))
                else:
                    # light
                    entity_material = Material[T, dim](DiffuseLight[T, dim](Color4[T](6.0,6.0,6.0,1)))
                
                var entity_id = store.create_entity()
                _ = store.add_components(
                    entity_id,
                    center,
                    entity_geometry,
                    entity_material
                )
                if entity_orientation:
                    _ = store.add_components(
                        entity_id,
                        entity_orientation.value()
                    )
    # Big Spheres
    var mat1 = Material[T, dim](Dielectric[T, dim](1.5))
    var sphere1 = Sphere[T, dim](1.0)
    var sphere1_entity_id = store.create_entity()
    _ = store.add_components(sphere1_entity_id, Point[T, dim](0, 1, 0), Geometry[T, dim](sphere1), mat1)

    var texture2 = Texture[T, dim](Solid[T,dim](Color4[T](0.4, 0.2, 0.1)))
    var mat2 = Material[T, dim](Lambertian[T, dim](texture2))
    var sphere2 = Sphere[T, dim](1.0)
    var sphere2_entity_id = store.create_entity()
    _ = store.add_components(sphere2_entity_id, Point[T, dim](-4, 1, 0), Geometry[T, dim](sphere2), mat2)

    var mat3 = Material[T, dim](Metal[T, dim](Color4[T](0.7, 0.6, 0.5), 0.0))
    var sphere3 = Sphere[T, dim](1.0)
    var sphere3_entity_id = store.create_entity()
    _ = store.add_components(sphere3_entity_id, Point[T, dim](4, 1, 0), Geometry[T, dim](sphere3), mat3)

    # Add physics objects for all the mobile bits
    for entity_id in store.get_entities_with_components(ComponentType.Geometry):
        var geom = store.geometry_components[
            store.entity_to_components[entity_id[]][ComponentType.Geometry]
        ]
        # Add to all spheres is we havent set up a special component
        if geom._hittable.isa[Sphere[T, dim]]() and not store.entity_has_components(entity_id[], ComponentType.PhysicsComponent):
            var rad = geom._hittable[Sphere[T, dim]]._radius
            _ = store.add_component(
                entity_id[], 
                PhysData[T](PhysGeom[T](PhysSphere[T](rad)), True)
            )