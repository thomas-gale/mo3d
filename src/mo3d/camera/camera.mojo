from algorithm import parallelize, vectorize
from math import inf, iota, pi
from math.math import tan
from random import random_float64

from max.tensor import Tensor

from mo3d.precision import int_type, float_type
from mo3d.math.angle import degrees_to_radians
from mo3d.math.interval import Interval
from mo3d.math.vec4 import Vec4
from mo3d.math.mat4 import Mat4
from mo3d.math.point4 import Point4
from mo3d.ray.color4 import Color4
from mo3d.ray.ray4 import Ray4
from mo3d.ray.hittable_list import HittableList
from mo3d.ray.hittable import HitRecord


@value
struct Camera[
    width: Int,
    height: Int,
    channels: Int,
    max_depth: Int,
    max_samples: Int,
]:
    alias S4 = SIMD[float_type, 4]

    var _vfov: Scalar[float_type]  # Vertical field of view
    var _focal_length: Scalar[float_type]

    var _look_from: Point4[float_type]  # Point camera is looking from
    var _look_at: Point4[float_type]  # Point camera is looking at
    var _vup: Vec4[float_type]  # Camera relative 'up' vector

    var _rot: Mat4[float_type]  # Camera rotation matrix

    var _viewport_height: Scalar[float_type]
    var _viewport_width: Scalar[float_type]

    var _pixel00_loc: Point4[float_type]  # Location of pixel 0, 0
    var _pixel_delta_u: Vec4[float_type]  # Offset to pixel to the right
    var _pixel_delta_v: Vec4[float_type]  # Offset to pixel below

    # The state of the sensor of the camera (this data is copied to the window texture)
    var _sensor_state: UnsafePointer[Scalar[float_type]]
    var _sensor_samples: Int

    var _dragging: Bool  # Is the camera moving/dragging (e.g. mouse is down state)
    var _last_x: Int32  # Last x position of the mouse
    var _last_y: Int32  # Last y position of the mouse

    fn __init__(
        inout self,
    ):
        # Set default field of view, starting position (look from), target (look at) and orientation (up vector)
        self._vfov = Scalar[float_type](70.0)
        self._look_from = Point4(Self.S4(0, 0, 3, 0))
        self._look_at = Point4(Self.S4(0, 0, 0, 0))
        self._vup = Vec4(Self.S4(0, 1, 0, 0))

        # Determine viewport dimensions
        self._focal_length = 1.0
        var theta: Scalar[float_type] = degrees_to_radians(self._vfov)
        var h: Scalar[float_type] = tan(theta / 2.0)
        self._viewport_height = 2.0 * h * self._focal_length
        self._viewport_width = self._viewport_height * (
            Scalar[float_type](width) / Scalar[float_type](height)
        )

        # Calculate the u,v,w basis vectors for the camera orientation. - TODO: somehow refactor the code to use update view matrix (however)
        var w = Vec4.unit(self._look_from - self._look_at)
        var u = Vec4.cross(self._vup, w)
        var v = Vec4.cross(w, u)
        self._rot = Mat4[float_type](
            u, v, w, Point4[float_type](Self.S4(0, 0, 0, 1))
        )

        # Calculate the vectors across the horizontal and down the vertical viewport edges.
        var viewport_u = self._viewport_width * self._rot.u
        var viewport_v = self._viewport_height * -self._rot.v

        # Calculate the horizontal and vertical delta vectors from pixel to pixel.
        self._pixel_delta_u = viewport_u / Scalar[float_type](width)
        self._pixel_delta_v = viewport_v / Scalar[float_type](height)

        # Calculate the location of the upper left pixel.
        var viewport_upper_left = self._look_from - (
            self._focal_length * self._rot.w
        ) - viewport_u / 2 - viewport_v / 2
        self._pixel00_loc = viewport_upper_left + 0.5 * (
            self._pixel_delta_u + self._pixel_delta_v
        )

        # Initialize the render state of the camera 'sensor'
        self._sensor_state = UnsafePointer[Scalar[float_type]].alloc(
            height * width * channels
        )
        for i in range(height * width * channels):
            (self._sensor_state + i)[] = 1.0
        self._sensor_samples = 0

        # Initialize the dragging/movement state of the camera
        self._dragging = False
        self._last_x = 0
        self._last_y = 0

        print("Camera initialized")

    fn __del__(owned self):
        self._sensor_state.free()
        print("Camera destroyed")

    fn update_view_matrix(
        inout self,
    ) -> None:
        self._rot.w = Vec4.unit(self._look_from - self._look_at)
        self._rot.u = Vec4.cross(self._vup, self._rot.w).unit()
        self._rot.v = Vec4.cross(self._rot.w, self._rot.u).unit()

        var viewport_u = self._viewport_width * self._rot.u
        var viewport_v = self._viewport_height * -self._rot.v

        # Calculate the horizontal and vertical delta vectors from pixel to pixel.
        self._pixel_delta_u = viewport_u / Scalar[float_type](width)
        self._pixel_delta_v = viewport_v / Scalar[float_type](height)

        # Calculate the location of the upper left pixel.
        var viewport_upper_left = self._look_from - (
            self._focal_length * self._rot.w
        ) - viewport_u / 2 - viewport_v / 2
        self._pixel00_loc = viewport_upper_left + 0.5 * (
            self._pixel_delta_u + self._pixel_delta_v
        )

    fn arcball(inout self, x: Int32, y: Int32) -> None:
        """
        Rotate the camera around the center of the scene.
        Attribution: https://asliceofrendering.com/camera/2019/11/30/ArcballCamera/.
        """
        if not self._dragging:
            return

        self._sensor_samples = 0  # Reset samples (so that sensor doesn't accumulate a blend of old/new positions)

        # Get the homogenous position of the camera and pivot point
        var position = Vec4(
            Self.S4(
                self._look_from.x(), self._look_from.y(), self._look_from.z(), 1
            )
        )
        var pivot = Vec4(
            Self.S4(self._look_at.x(), self._look_at.y(), self._look_at.z(), 1)
        )

        # Step 1 : Calculate the amount of rotation given the mouse movement.
        var delta_angle_x = 2 * Scalar[float_type](pi) / Scalar[float_type](
            width
        )
        var delta_angle_y = Scalar[float_type](pi) / Scalar[float_type](height)
        var x_angle = (self._last_x - x).cast[float_type]() * -delta_angle_x
        var y_angle = (self._last_y - y).cast[float_type]() * -delta_angle_y

        print("X angle: " + str(x_angle))
        print("Y angle: " + str(y_angle))

        # Extra step to handle the problem when the camera direction is the same as the up vector
        var cos_angle = Vec4.dot(self._rot.w, self._vup)
        if (
            cos_angle
            * (
                (Scalar[float_type](0.0) < y_angle).cast[float_type]()
                - (y_angle < Scalar[float_type](0.0)).cast[float_type]()
            )
        ) > 0.99:
            y_angle = 0

        # Step 2: Rotate the camera around the pivot point on the first axis.
        var rotation_matrix_x = Mat4[float_type].eye()
        rotation_matrix_x = rotation_matrix_x.rotate(x_angle, self._rot.v)
        position = (rotation_matrix_x * (position - pivot)) + pivot

        # Step 3: Rotate the camera around the pivot point on the second axis.
        var rotation_matrix_y = Mat4[float_type].eye()
        rotation_matrix_y = rotation_matrix_y.rotate(y_angle, self._rot.u)
        var final_position = (rotation_matrix_y * (position - pivot)) + pivot

        # Update the camera view (we keep the same lookat and the same up vector)
        self._look_from = final_position
        self.update_view_matrix()

        print("View matrix updated")
        print(str(self._rot))

        # Update the mouse position for the next rotation
        self._last_x = x
        self._last_y = y

    fn start_dragging(inout self, x: Int32, y: Int32) -> None:
        self._last_x = x
        self._last_y = y
        self._dragging = True

    fn stop_dragging(inout self) -> None:
        self._dragging = False

    fn get_state(self) -> UnsafePointer[Scalar[float_type]]:
        return self._sensor_state

    fn render(inout self, world: HittableList, num_samples: Int = 1):
        """
        Parallelize render, one row for each thread.
        TODO: Switch to one thread per pixel and compare performance (one we're running on GPU).
        """

        self._sensor_samples += 1

        # Don't render more than max_samples
        if self._sensor_samples > max_samples:
            return

        @parameter
        fn compute_row(y: Int):
            @parameter
            fn compute_row_vectorize[simd_width: Int](x: Int):
                # Send a ray into the scene from this x, y coordinate
                var pixel_samples_scale = 1.0 / Scalar[float_type](num_samples)
                var pixel_color = Color4(Self.S4(0, 0, 0, 0))
                for _ in range(num_samples):
                    var r = self.get_ray(x, y)
                    pixel_color += Self._ray_color(r, max_depth, world)
                pixel_color *= pixel_samples_scale.cast[float_type]()

                # Progressivelh store the color in the render state
                (
                    self._sensor_state + (y * (width * channels) + x * channels)
                )[] *= Scalar[float_type](self._sensor_samples - 1) / Scalar[
                    float_type
                ](
                    self._sensor_samples
                )
                (
                    self._sensor_state + (y * (width * channels) + x * channels)
                )[] += pixel_color.w() / Scalar[float_type](
                    self._sensor_samples
                )

                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 1)
                )[] *= Scalar[float_type](self._sensor_samples - 1) / Scalar[
                    float_type
                ](
                    self._sensor_samples
                )
                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 1)
                )[] += pixel_color.z() / Scalar[float_type](
                    self._sensor_samples
                )

                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 2)
                )[] *= Scalar[float_type](self._sensor_samples - 1) / Scalar[
                    float_type
                ](
                    self._sensor_samples
                )
                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 2)
                )[] += pixel_color.y() / Scalar[float_type](
                    self._sensor_samples
                )

                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 3)
                )[] *= Scalar[float_type](self._sensor_samples - 1) / Scalar[
                    float_type
                ](
                    self._sensor_samples
                )
                (
                    self._sensor_state
                    + (y * (width * channels) + x * channels + 3)
                )[] += pixel_color.x() / Scalar[float_type](
                    self._sensor_samples
                )

            vectorize[compute_row_vectorize, 1](width)

        parallelize[compute_row](height, height)

    fn get_ray(
        self, i: Scalar[int_type], j: Scalar[int_type]
    ) -> Ray4[float_type]:
        var offset = Self._sample_square()

        var pixel_sample = self._pixel00_loc + (
            (i.cast[float_type]() + offset.x()) * self._pixel_delta_u
        ) + ((j.cast[float_type]() + offset.y()) * self._pixel_delta_v)

        var ray_origin = self._look_from
        var ray_direction = pixel_sample - ray_origin

        return Ray4(ray_origin, ray_direction)

    @staticmethod
    fn _sample_square() -> Vec4[float_type]:
        """
        Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
        """
        return Vec4(
            Self.S4(
                random_float64().cast[float_type]() - 0.5,
                random_float64().cast[float_type]() - 0.5,
                0.0,
                0.0,
            )
        )

    @staticmethod
    @parameter
    fn _ray_color(
        r: Ray4[float_type], depth: Scalar[int_type], world: HittableList
    ) -> Color4[float_type]:
        """
        Sadly can't get the generic hittable trait as argument type to work :(.
        """
        if depth <= 0:
            return Color4(
                Self.S4(0, 0, 0, 0)
            )  # TODO: What should be alpha here?

        var rec = HitRecord[float_type]()

        if world.hit(r, Interval[float_type](0.001, inf[float_type]()), rec):
            var direction = rec.normal + Vec4[float_type].random_unit_vector()
            return 0.5 * Self._ray_color(
                Ray4[float_type](rec.p, direction), depth - 1, world
            )

        var unit_direction = Vec4.unit(r.dir)
        var a = 0.5 * (unit_direction.y() + 1.0)
        return (1.0 - a) * Color4(Self.S4(1.0, 1.0, 1.0, 1.0)) + a * Color4(
            Self.S4(0.5, 0.7, 1.0, 1.0)
        )
