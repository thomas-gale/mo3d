from collections import List, Dict, Set
from utils import Variant

from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.math.mat import Mat

from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import (
    ComponentID,
    ComponentTypeID,
    ComponentType,
    PositionComponent,
    VelocityComponent,
    OrientationComponent,
    GeometryComponent,
    MaterialComponent,
    BoundingBoxComponent,
    BinaryChildrenComponent,
)


@value
struct ComponentStore[T: DType, dim: Int]:
    """
    It will be nice to move the component store data to some variadic comptime SoA design.
    While experimenting with Proof of Concept, I will keep it simple and have hardcoded component lists for each component type.

    Experimenting with direct and inverted indexing for entity to component mapping.
    Having both will allow for faster access to components given an entity and vice versa however presents a challenge in keeping the two in sync and a larger memory footprint.
    """

    alias ComponentVariants = Variant[
        PositionComponent[T, dim],
        VelocityComponent[T, dim],
        OrientationComponent[T, dim],
        GeometryComponent[T, dim],
        MaterialComponent[T, dim],
        BoundingBoxComponent[T, dim],
        BinaryChildrenComponent,
    ]

    var position_components: List[PositionComponent[T, dim]]
    var position_component_to_entities: Dict[ComponentID, EntityID]

    var velocity_components: List[VelocityComponent[T, dim]]
    var velocity_component_to_entities: Dict[ComponentID, EntityID]

    var orientation_components: List[OrientationComponent[T, dim]]
    var orientation_component_to_entities: Dict[ComponentID, EntityID]

    var geometry_components: List[GeometryComponent[T, dim]]
    var geometry_component_to_entities: Dict[ComponentID, EntityID]

    var material_components: List[MaterialComponent[T, dim]]
    var material_component_to_entities: Dict[ComponentID, EntityID]

    var bounding_box_components: List[BoundingBoxComponent[T, dim]]
    var bounding_box_component_to_entities: Dict[ComponentID, EntityID]

    var binary_children_components: List[BinaryChildrenComponent]
    var binary_children_component_to_entities: Dict[ComponentID, EntityID]

    var entity_to_components: Dict[EntityID, Dict[ComponentTypeID, ComponentID]]
    var entity_to_component_type_mask: Dict[EntityID, ComponentTypeID]

    fn __init__(inout self):
        self.position_components = List[PositionComponent[T, dim]]()
        self.position_component_to_entities = Dict[ComponentID, EntityID]()

        self.velocity_components = List[VelocityComponent[T, dim]]()
        self.velocity_component_to_entities = Dict[ComponentID, EntityID]()

        self.orientation_components = List[OrientationComponent[T, dim]]()
        self.orientation_component_to_entities = Dict[ComponentID, EntityID]()

        self.geometry_components = List[GeometryComponent[T, dim]]()
        self.geometry_component_to_entities = Dict[ComponentID, EntityID]()

        self.material_components = List[MaterialComponent[T, dim]]()
        self.material_component_to_entities = Dict[ComponentID, EntityID]()

        self.bounding_box_components = List[BoundingBoxComponent[T, dim]]()
        self.bounding_box_component_to_entities = Dict[ComponentID, EntityID]()

        self.binary_children_components = List[BinaryChildrenComponent]()
        self.binary_children_component_to_entities = Dict[
            ComponentID, EntityID
        ]()

        self.entity_to_components = Dict[
            EntityID, Dict[ComponentTypeID, ComponentID]
        ]()
        self.entity_to_component_type_mask = Dict[EntityID, ComponentTypeID]()

    fn _add_position_component(
        inout self, entity_id: EntityID, component: PositionComponent[T, dim]
    ) raises -> ComponentID:
        if (
            self.entity_to_component_type_mask[entity_id]
            & ComponentType.Position
        ):
            raise Error("Entity already has a position component")
        self.position_components.append(component)
        var component_id = ComponentID(len(self.position_components) - 1)
        self.position_component_to_entities[component_id] = entity_id

        self.entity_to_components[entity_id][
            ComponentType.Position
        ] = component_id
        self.entity_to_component_type_mask[entity_id] |= ComponentType.Position

        return component_id

    fn _add_velocity_component(
        inout self, entity_id: EntityID, component: VelocityComponent[T, dim]
    ) raises -> ComponentID:
        if (
            self.entity_to_component_type_mask[entity_id]
            & ComponentType.Velocity
        ):
            raise Error("Entity already has a velocity component")

        self.velocity_components.append(component)
        var component_id = ComponentID(len(self.velocity_components) - 1)
        self.velocity_component_to_entities[component_id] = entity_id

        self.entity_to_components[entity_id][
            ComponentType.Velocity
        ] = component_id
        self.entity_to_component_type_mask[entity_id] |= ComponentType.Velocity

        return component_id

    fn _add_geometry_component(
        inout self, entity_id: EntityID, component: GeometryComponent[T, dim]
    ) raises -> ComponentID:
        if (
            self.entity_to_component_type_mask[entity_id]
            & ComponentType.Geometry
        ):
            raise Error("Entity already has a geometry component")

        self.geometry_components.append(component)
        var component_id = ComponentID(len(self.geometry_components) - 1)
        self.geometry_component_to_entities[component_id] = entity_id

        self.entity_to_components[entity_id][
            ComponentType.Geometry
        ] = component_id
        self.entity_to_component_type_mask[entity_id] |= ComponentType.Geometry

        return component_id

    fn _add_material_component(
        inout self, entity_id: EntityID, component: MaterialComponent[T, dim]
    ) raises -> ComponentID:
        if (
            self.entity_to_component_type_mask[entity_id]
            & ComponentType.Material
        ):
            raise Error("Entity already has a material component")

        self.material_components.append(component)
        var component_id = ComponentID(len(self.material_components) - 1)
        self.material_component_to_entities[component_id] = entity_id

        self.entity_to_components[entity_id][
            ComponentType.Material
        ] = component_id
        self.entity_to_component_type_mask[entity_id] |= ComponentType.Material

        return component_id

    fn _add_bounding_box_component(
        inout self, entity_id: EntityID, component: BoundingBoxComponent[T, dim]
    ) raises -> ComponentID:
        if (
            self.entity_to_component_type_mask[entity_id]
            & ComponentType.BoundingBox
        ):
            raise Error("Entity already has a bounding box component")

        self.bounding_box_components.append(component)
        var component_id = ComponentID(len(self.bounding_box_components) - 1)
        self.bounding_box_component_to_entities[component_id] = entity_id

        self.entity_to_components[entity_id][
            ComponentType.BoundingBox
        ] = component_id
        self.entity_to_component_type_mask[
            entity_id
        ] |= ComponentType.BoundingBox

        return component_id

    fn _add_binary_children_component(
        inout self, entity_id: EntityID, component: BinaryChildrenComponent
    ) raises -> ComponentID:
        if (
            self.entity_to_component_type_mask[entity_id]
            & ComponentType.BinaryChildren
        ):
            raise Error("Entity already has a binary children component")

        self.binary_children_components.append(component)
        var component_id = ComponentID(len(self.binary_children_components) - 1)
        self.binary_children_component_to_entities[component_id] = entity_id

        self.entity_to_components[entity_id][
            ComponentType.BinaryChildren
        ] = component_id
        self.entity_to_component_type_mask[
            entity_id
        ] |= ComponentType.BinaryChildren

        return component_id

    fn create_entity(inout self) -> EntityID:
        """
        This implementation is not thread safe.
        """
        var entity_id = EntityID(len(self.entity_to_components))
        self.entity_to_components[entity_id] = Dict[
            ComponentTypeID, ComponentID
        ]()
        self.entity_to_component_type_mask[entity_id] = 0
        return entity_id

    fn add_component(
        inout self, entity_id: EntityID, component: Self.ComponentVariants
    ) raises -> ComponentID:
        """
        This implementation is probably not thread safe.
        We need to lock a given entity_id before adding a component to it.
        """
        if entity_id not in self.entity_to_components:
            raise Error("Entity does not exist")

        if component.isa[PositionComponent[T, dim]]():
            return self._add_position_component(
                entity_id, component[Point[T, dim]]
            )
        elif component.isa[VelocityComponent[T, dim]]():
            return self._add_velocity_component(
                entity_id, component[Vec[T, dim]]
            )
        elif component.isa[GeometryComponent[T, dim]]():
            return self._add_geometry_component(
                entity_id, component[GeometryComponent[T, dim]]
            )
        elif component.isa[MaterialComponent[T, dim]]():
            return self._add_material_component(
                entity_id, component[MaterialComponent[T, dim]]
            )
        elif component.isa[BoundingBoxComponent[T, dim]]():
            return self._add_bounding_box_component(
                entity_id, component[BoundingBoxComponent[T, dim]]
            )
        elif component.isa[BinaryChildrenComponent]():
            return self._add_binary_children_component(
                entity_id, component[BinaryChildrenComponent]
            )
        else:
            raise Error("Unknown component type")

    fn add_components(
        inout self,
        entity_id: EntityID,
        components: List[Self.ComponentVariants],
    ) raises -> List[ComponentID]:
        var component_ids = List[ComponentID]()
        for component in components:
            component_ids.append(self.add_component(entity_id, component))
        return component_ids

    fn add_components(
        inout self,
        entity_id: EntityID,
        *components: Self.ComponentVariants,
    ) raises -> List[ComponentID]:
        var component_ids = List[ComponentID]()
        for component in components:
            component_ids.append(self.add_component(entity_id, component[]))
        return component_ids

    fn entity_has_components(
        self, entity_id: EntityID, component_type_mask: ComponentTypeID
    ) -> Bool:
        """
        Using bitwise OR to check if the queried component type mask is a subset of the entity's component type mask.

        Example:
        entity_has_components(entity_id, ComponentType.Position | ComponentType.Velocity).
        """
        try:
            return (
                component_type_mask
                | self.entity_to_component_type_mask[entity_id]
            ) == self.entity_to_component_type_mask[entity_id]
        except:
            return False

    fn get_entities_with_components(
        self, component_type_mask: ComponentTypeID
    ) -> List[EntityID]:
        """
        WIP: Very hacky initial implementation.
        """
        var entities = List[EntityID]()
        for entity_id in self.entity_to_component_type_mask:
            # Queried component type mask is a subset of the entity's component type mask.
            if self.entity_has_components(entity_id[], component_type_mask):
                entities.append(entity_id[])
        return entities
