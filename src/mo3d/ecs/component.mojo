from mo3d.math.vec import Vec
from mo3d.math.mat import Mat
from mo3d.math.point import Point
from mo3d.material.material import Material
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.aabb import AABB

from mo3d.ecs.entity import EntityID


alias PositionComponent = Point

alias VelocityComponent = Vec

alias OrientationComponent = Mat

alias GeometryComponent = Geometry

alias MaterialComponent = Material

alias BoundingBoxComponent = AABB


@value
struct BinaryChildrenComponent:
    var left: EntityID
    var right: EntityID


alias ComponentID = Int

alias ComponentTypeID = Int


struct ComponentType:
    alias Position: ComponentTypeID = 1 << 0
    alias Velocity: ComponentTypeID = 1 << 1
    alias Orientation: ComponentTypeID = 1 << 2
    alias Geometry: ComponentTypeID = 1 << 3
    alias Material: ComponentTypeID = 1 << 4
    alias BoundingBox: ComponentTypeID = 1 << 5
    alias BinaryChildren: ComponentTypeID = 1 << 6
