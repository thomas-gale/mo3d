from algorithm import parallelize, vectorize
from math import inf, iota, pi
from math.math import tan
from random import random_float64

from max.tensor import Tensor

from mo3d.math.angle import degrees_to_radians
from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.mat import Mat
from mo3d.math.point import Point
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord
from mo3d.ray.hit_entity import hit_entity

from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import (
    ComponentID,
    ComponentType,
    PositionComponent,
    GeometryComponent,
)
from mo3d.ecs.component_store import ComponentStore

from mo3d.gui.pil import PIL


@value
struct Camera[
    T: DType,
    fov: Scalar[T],
    aperature: Scalar[T],
    width: Int,
    height: Int,
    channels: Int,
    max_depth: Int,
    max_samples: Int,
    dim: Int = 3,
]:
    var _focal_length: Scalar[
        T
    ]  #  # Distance from camera lookfrom point to plane of perfect focus and centre of pivot for arcball rotation

    var _look_from: Point[T, dim]  # Point camera is looking from
    var _look_at: Point[T, dim]  # Point camera is looking at
    var _vup: Vec[T, dim]  # Camera relative 'up' vector

    var _rot: Mat[T, dim]  # Camera rotation matrix
    var _defocus_disk_u: Vec[T, dim]  # Defocus horizontal radius
    var _defocus_disk_v: Vec[T, dim]  # Defocus vertical radius

    var _viewport_height: Scalar[T]
    var _viewport_width: Scalar[T]

    var _pixel00_loc: Point[T, dim]  # Location of pixel 0, 0
    var _pixel_delta_u: Vec[T, dim]  # Offset to pixel to the right
    var _pixel_delta_v: Vec[T, dim]  # Offset to pixel below

    # The state of the sensor of the camera (this data is copied to the window texture)
    var _sensor_state: UnsafePointer[Scalar[T]]
    var _sensor_samples: Int

    var _dragging: Bool  # Is the camera moving/dragging (e.g. mouse is down state)
    var _last_x: Int32  # Last x position of the mouse
    var _last_y: Int32  # Last y position of the mouse

    fn __init__(
        inout self,
    ) raises -> None:
        # Set default field of view, starting position (look from), target (look at) and orientation (up vector)
        # self._look_from = Point[T, dim](13, 2, 3)
        # self._look_at = Point[T, dim](0, 0, 0)

        self._look_from = Point[T, dim](0, 0, 15)
        self._look_at = Point[T, dim](0, 1, 0)

        self._vup = Vec[T, dim](0, 1, 0)

        # Determine viewport dimensions
        self._focal_length = (self._look_from - self._look_at).length()
        var theta: Scalar[T] = degrees_to_radians(fov)
        var h: Scalar[T] = tan(theta / 2.0)
        self._viewport_height = 2.0 * h * self._focal_length
        self._viewport_width = self._viewport_height * (
            Scalar[T](width) / Scalar[T](height)
        )

        # Calculate the u,v,w basis vectors for the camera orientation. - TODO: somehow refactor the code to use update view matrix (however)
        var w = Vec.unit(self._look_from - self._look_at)
        var u = Vec.cross_3(self._vup, w)
        var v = Vec.cross_3(w, u)
        self._rot = Mat[T, dim](u, v, w)

        # Calculate the vectors across the horizontal and down the vertical viewport edges.
        var viewport_u = self._viewport_width * self._rot[0]
        var viewport_v = self._viewport_height * -self._rot[1]

        # Calculate the horizontal and vertical delta vectors from pixel to pixel.
        self._pixel_delta_u = viewport_u / Scalar[T](width)
        self._pixel_delta_v = viewport_v / Scalar[T](height)

        # Calculate the location of the upper left pixel.
        var viewport_upper_left = self._look_from - (
            self._focal_length * self._rot[2]
        ) - viewport_u / 2 - viewport_v / 2
        self._pixel00_loc = viewport_upper_left + 0.5 * (
            self._pixel_delta_u + self._pixel_delta_v
        )

        # Calculate the camera defocus disk basis vectors.
        # self._defocus_angle = Scalar[T](10.0) # Simulate a large aperature
        var defocus_radius = self._focal_length * tan(
            degrees_to_radians(aperature / 2)
        )
        self._defocus_disk_u = u * defocus_radius
        self._defocus_disk_v = v * defocus_radius

        # Initialize the render state of the camera 'sensor'
        self._sensor_state = UnsafePointer[Scalar[T]].alloc(
            height * width * channels
        )
        for i in range(height * width * channels):
            (self._sensor_state + i)[] = 1.0
        self._sensor_samples = 0

        # Initialize the dragging/movement state of the camera
        self._dragging = False
        self._last_x = 0
        self._last_y = 0

        # Do a final update of the view matrix: TODO: Remove the duplicate code above.
        self.update_view_matrix()

        print("Camera initialized")

    fn __del__(owned self):
        self._sensor_state.free()
        print("Camera destroyed")

    fn update_view_matrix(
        inout self,
    ) raises -> None:
        self._rot[2] = (self._look_from - self._look_at).unit()
        self._rot[0] = Vec.cross_3(self._vup, self._rot[2]).unit()
        self._rot[1] = Vec.cross_3(self._rot[2], self._rot[0]).unit()

        var viewport_u = self._viewport_width * self._rot[0]
        var viewport_v = self._viewport_height * -self._rot[1]

        # Calculate the horizontal and vertical delta vectors from pixel to pixel.
        self._pixel_delta_u = viewport_u / Scalar[T](width)
        self._pixel_delta_v = viewport_v / Scalar[T](height)

        # Calculate the location of the upper left pixel.
        var viewport_upper_left = self._look_from - (
            self._focal_length * self._rot[2]
        ) - viewport_u / 2 - viewport_v / 2
        self._pixel00_loc = viewport_upper_left + 0.5 * (
            self._pixel_delta_u + self._pixel_delta_v
        )

    fn arcball(inout self, x: Int32, y: Int32) raises -> None:
        """
        Rotate the camera around the center of the scene.
        Attribution: https://asliceofrendering.com/camera/2019/11/30/ArcballCamera/.
        """
        if not self._dragging:
            return

        self._sensor_samples = 0  # Reset samples (so that sensor doesn't accumulate a blend of old/new positions)

        # Get the homogenous position of the camera and pivot point
        var position = Vec[T, dim](
            self._look_from[0], self._look_from[1], self._look_from[2]
        )
        var pivot = Vec[T, dim](
            self._look_at[0], self._look_at[1], self._look_at[2]
        )

        # Step 1 : Calculate the amount of rotation given the mouse movement.
        var delta_angle_x = 2 * Scalar[T](pi) / Scalar[T](width)
        var delta_angle_y = Scalar[T](pi) / Scalar[T](height)
        var x_angle = (self._last_x - x).cast[T]() * -delta_angle_x
        var y_angle = (self._last_y - y).cast[T]() * -delta_angle_y

        # Extra step to handle the problem when the camera direction is the same as the up vector
        var cos_angle = Vec.dot(self._rot[2], self._vup)
        if (
            cos_angle
            * (
                (Scalar[T](0.0) < y_angle).cast[T]()
                - (y_angle < Scalar[T](0.0)).cast[T]()
            )
        ) > 0.99:
            y_angle = 0

        # Step 2: Rotate the camera around the pivot point on the first axis.
        var rotation_matrix_x = Mat[T, dim].eye()
        rotation_matrix_x = Mat[T, dim].rotate_3(
            rotation_matrix_x, x_angle, self._vup
        )
        position = (rotation_matrix_x * (position - pivot)) + pivot

        # Step 3: Rotate the camera around the pivot point on the second axis.
        var rotation_matrix_y = Mat[T, dim].eye()
        rotation_matrix_y = Mat[T, dim].rotate_3(
            rotation_matrix_y, y_angle, self._rot[0]
        )
        var final_position = (rotation_matrix_y * (position - pivot)) + pivot

        # Update the camera view (we keep the same lookat and the same up vector)
        self._look_from = final_position
        self.update_view_matrix()

        # Update the mouse position for the next rotation
        self._last_x = x
        self._last_y = y

    fn start_dragging(inout self, x: Int32, y: Int32) -> None:
        self._last_x = x
        self._last_y = y
        self._dragging = True

    fn stop_dragging(inout self) -> None:
        self._dragging = False

    fn get_state(self) -> UnsafePointer[Scalar[T]]:
        return self._sensor_state

    fn render(
        inout self,
        store: ComponentStore[T, dim],
        bvh_root_entity: EntityID,
        compute_time_ms: Int32,
        redraw_time_ns: Int32,
        num_samples: Int = 1
        # inout self, world: HittableList[T, dim], compute_time_ms: Int32, redraw_time_ns: Int32, num_samples: Int = 1
    ) raises:
        """
        Parallelize render, one row for each thread.
        TODO: Switch to one thread per pixel and compare performance (one we're running on GPU).
        """

        self._sensor_samples += 1

        # Don't render more than max_samples
        if self._sensor_samples > max_samples:
            return

        # Get hittable components
        # var hitables = store.get_entities_with_components(
        #     ComponentType.Position
        #     | ComponentType.Geometry
        #     | ComponentType.Material
        # )

        # var hitable_positions = List[ComponentID]()
        # var hitable_geometeries = List[ComponentID]()
        # var hitable_materials = List[ComponentID]()
        # for hitable in hitables:
        #     hitable_positions.append(
        #         store.entity_to_components[hitable[]][ComponentType.Position]
        #     )
        #     hitable_geometeries.append(
        #         store.entity_to_components[hitable[]][ComponentType.Geometry]
        #     )
        #     hitable_materials.append(
        #         store.entity_to_components[hitable[]][ComponentType.Material]
        #     )

        # All captured references are unsafe references: https://docs.modular.com/mojo/roadmap#parameter-closure-captures-are-unsafe-references
        @parameter
        fn compute_row(y: Int):
            @parameter
            fn compute_row_vectorize[simd_width: Int](x: Int):
                # Send a ray into the scene from this x, y coordinate
                var pixel_samples_scale = 1.0 / Scalar[T](num_samples)
                var pixel_color = Color4[T](0, 0, 0, 0)
                for _ in range(num_samples):
                    var r = self.get_ray(x, y)
                    pixel_color += Self._ray_color(
                        r,
                        max_depth,
                        store,
                        bvh_root_entity,
                        # hitable_positions,
                        # hitable_geometeries,
                        # hitable_materials,
                    )
                pixel_color *= pixel_samples_scale.cast[T]()

                # Progressively store the color in the render state
                (
                    self._sensor_state + (y * (width * channels) + x * channels)
                )[] *= Scalar[T](self._sensor_samples - 1) / Scalar[T](
                    self._sensor_samples
                )
                (
                    self._sensor_state + (y * (width * channels) + x * channels)
                )[] += pixel_color[3] / Scalar[T](self._sensor_samples)

                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 1)
                )[] *= Scalar[T](self._sensor_samples - 1) / Scalar[T](
                    self._sensor_samples
                )
                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 1)
                )[] += pixel_color[2] / Scalar[T](self._sensor_samples)

                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 2)
                )[] *= Scalar[T](self._sensor_samples - 1) / Scalar[T](
                    self._sensor_samples
                )
                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 2)
                )[] += pixel_color[1] / Scalar[T](self._sensor_samples)

                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 3)
                )[] *= Scalar[T](self._sensor_samples - 1) / Scalar[T](
                    self._sensor_samples
                )
                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 3)
                )[] += pixel_color[0] / Scalar[T](self._sensor_samples)

            vectorize[compute_row_vectorize, 1](width)

        parallelize[compute_row](height, height)

        # Required because compute_row parametric captured values are unsafe references: https://docs.modular.com/mojo/roadmap#parameter-closure-captures-are-unsafe-references
        # _ = hitable_positions
        # _ = hitable_geometeries
        # _ = hitable_materials

        # Some experimental code to render text to the texture
        # var p = PIL()
        # p.render_to_texture[T](
        #     self._sensor_state,
        #     width,
        #     10,
        #     10,
        #     "average compute: " + str(compute_time_ms) + " ms",
        # )
        # p.render_to_texture(
        #     self._sensor_state,
        #     width,
        #     10,
        #     25,
        #     "average redraw: " + str(redraw_time_ns) + " ns",
        # )

    fn get_ray(self, i: Int, j: Int) -> Ray[T, dim]:
        var offset = Self._sample_square()

        var pixel_sample = self._pixel00_loc + (
            (Scalar[T](i) + offset[0]) * self._pixel_delta_u
        ) + ((Scalar[T](j) + offset[1]) * self._pixel_delta_v)

        var ray_origin = self._look_from if aperature <= 0.0 else self._defocus_disk_sample()
        var ray_direction = pixel_sample - ray_origin
        var ray_time = random_float64().cast[T]()

        return Ray(ray_origin, ray_direction, ray_time)

    @staticmethod
    fn _sample_square() -> Vec[T, dim]:
        """
        Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
        """
        return Vec[T, dim](
            random_float64().cast[T]() - 0.5,
            random_float64().cast[T]() - 0.5,
            0.0,
        )

    fn _defocus_disk_sample(self) -> Point[T, dim]:
        """
        Returns a random point in the unit disk.
        """
        var p = Vec[T, dim].random_in_unit_disk()
        return (
            self._look_from
            + self._defocus_disk_u * p[0]
            + self._defocus_disk_v * p[1]
        )

    @staticmethod
    @parameter
    fn _ray_color(
        r: Ray[T, dim],
        depth: Int,
        store: ComponentStore[T, dim],
        bvh_root_entity: EntityID,
        # hitable_positions: List[ComponentID],
        # hitable_geometeries: List[ComponentID],
        # hitable_materials: List[ComponentID],
    ) -> Color4[T]:
        """
        This is the first ECS 'system' like function that we're implementing in mo3d.
        """
        if depth <= 0:
            return Color4[T](0, 0, 0, 0)

        # TODO: Tidy massively (this 'system' is a mess)
        # First stage find the closest hit (this used to be handled by the HittableList)
        var ray_t = Interval[T](0.001, inf[T]())
        var rec = HitRecord[T, dim]()
        # var temp_rec = HitRecord[T, dim]()
        # var hit_anything = False
        # var closest_so_far = ray_t.max

        # for entity in range(len(hitable_positions)):
        #     var pos = store.position_components[hitable_positions[entity]]
        #     var geom = store.geometry_components[hitable_geometeries[entity]]
        #     var mat = store.material_components[hitable_materials[entity]]
        #     if geom.hit(
        #         r, Interval(ray_t.min, closest_so_far), temp_rec, pos, mat
        #     ):
        #         hit_anything = True
        #         closest_so_far = temp_rec.t
        #         rec = temp_rec

        # BVH traversal
        var hit_anything = hit_entity(store, bvh_root_entity, r, ray_t, rec)

        # If we hit something, scatter the ray and recurse
        if hit_anything:
            var scattered = Ray[T, dim]()
            var attenuation = Color4[T]()
            try:
                if rec.mat.scatter(r, rec, attenuation, scattered):
                    return attenuation * Self._ray_color(
                        scattered,
                        depth - 1,
                        store,
                        bvh_root_entity,
                        # hitable_positions,
                        # hitable_geometeries,
                        # hitable_materials,
                    )
            except:
                pass
            return Color4[T](0, 0, 0, 0)

        var unit_direction = Vec.unit(r.dir)
        var a = 0.5 * (unit_direction[1] + 1.0)
        return (1.0 - a) * Color4[T](1.0, 1.0, 1.0, 1.0) + a * Color4[T](
            0.5, 0.7, 1.0, 1.0
        )
