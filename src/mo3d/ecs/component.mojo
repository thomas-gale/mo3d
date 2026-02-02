from mo3d.math.vec import Vec
from mo3d.math.mat import RotMat
from mo3d.math.point import Point
from mo3d.material.material import Material
from mo3d.geometry.geometry import Geometry
from mo3d.geometry.aabb import AABB

from mo3d.ecs.entity import EntityID


comptime PositionComponent = Point

comptime VelocityComponent = Vec

comptime OrientationComponent = RotMat

comptime GeometryComponent = Geometry

comptime MaterialComponent = Material

comptime BoundingBoxComponent = AABB

comptime ComponentID = Int

comptime ComponentTypeID = Int


struct ComponentType:
    comptime Position: ComponentTypeID = 1 << 0
    comptime Velocity: ComponentTypeID = 1 << 1
    comptime Orientation: ComponentTypeID = 1 << 2
    comptime Geometry: ComponentTypeID = 1 << 3
    comptime Material: ComponentTypeID = 1 << 4
    comptime BoundingBox: ComponentTypeID = 1 << 5
