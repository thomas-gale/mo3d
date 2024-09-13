from collections import List, Dict
from utils import Variant

from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.math.mat import Mat
from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import ComponentID


struct ComponentStore[T: DType, dim: Int]:
    """
    This is a hardcoded mess while I figure a nicer way to do SoA in Mojo.
    """

    alias ComponentVariants = Variant[Point[T, dim], Vec[T, dim]]

    var position_components: List[Point[T, dim]]
    var orientation_components: List[Mat[T, dim]]
    var velocity_components: List[Vec[T, dim]]

    var entity_component_map: Dict[EntityID, List[ComponentID]]

    fn __init__(inout self) raises:
        self.position_components = List[Point[T, dim]]()
        self.orientation_components = List[Mat[T, dim]]()
        self.velocity_components = List[Vec[T, dim]]()
        self.entity_component_map = Dict[EntityID, List[ComponentID]]()

    fn _add_position_component(
        inout self, entity_id: EntityID, component: Point[T, dim]
    ) raises -> ComponentID:
        self.position_components.append(component)
        var component_id = ComponentID(len(self.position_components) - 1)
        self.entity_component_map[entity_id].append(component_id)
        return component_id

    fn _add_velocity_component(
        inout self, entity_id: EntityID, component: Vec[T, dim]
    ) raises -> ComponentID:
        self.velocity_components.append(component)
        var component_id = ComponentID(len(self.velocity_components) - 1)
        self.entity_component_map[entity_id].append(component_id)
        return component_id

    fn add_entity(inout self, entity_id: EntityID) raises:
        self.entity_component_map[entity_id] = List[ComponentID]()

    fn add_component(
        inout self, entity_id: EntityID, component: Self.ComponentVariants
    ) raises -> ComponentID:
        if component.isa[Point[T, dim]]():
            return self._add_position_component(
                entity_id, component[Point[T, dim]]
            )
        elif component.isa[Vec[T, dim]]():
            return self._add_velocity_component(
                entity_id, component[Vec[T, dim]]
            )
        else:
            raise Error("Unknown component type")
