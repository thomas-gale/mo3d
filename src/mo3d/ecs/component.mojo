from mo3d.math.vec import Vec
from mo3d.math.mat import RotMat
from mo3d.math.point import Point
from mo3d.material.material import Material
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.aabb import AABB
from mo3d.phys.data import PhysData

from mo3d.ecs.entity import EntityID


alias PositionComponent = Point

alias VelocityComponent = Vec

alias OrientationComponent = RotMat

alias GeometryComponent = Geometry

alias MaterialComponent = Material

alias BoundingBoxComponent = AABB

alias PhysicsComponent = PhysData

alias ComponentID = Int

alias ComponentTypeID = Int


struct ComponentType:
    alias Position: ComponentTypeID = 1 << 0
    alias Velocity: ComponentTypeID = 1 << 1
    alias Orientation: ComponentTypeID = 1 << 2
    alias Geometry: ComponentTypeID = 1 << 3
    alias Material: ComponentTypeID = 1 << 4
    alias BoundingBox: ComponentTypeID = 1 << 5
    alias PhysicsComponent : ComponentTypeID = 1 << 6
