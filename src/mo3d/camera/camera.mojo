from algorithm import parallelize, vectorize
from math import inf, iota, pi
from math.math import tan
from memory import UnsafePointer

from max.tensor import Tensor

from mo3d.math.angle import degrees_to_radians
from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.mat import Mat
from mo3d.math.point import Point
from mo3d.ray.color4 import Color4
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

from mo3d.scene.construct_bvh import BVHNode

from mo3d.random.rng import Rng

from mo3d.ecs.entity import EntityID
from mo3d.ecs.component import (
    ComponentID,
    ComponentType,
    PositionComponent,
    GeometryComponent,
)
from mo3d.ecs.component_store import ComponentStore

from mo3d.gui.pil import PIL


struct Camera[
    T: DType,
    fov: Scalar[T],
    aperature: Scalar[T],
    width: Int,
    height: Int,
    channels: Int,
    max_depth: Int,
    max_samples: Int,
    background: Color4[T],
    dim: Int = 3
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

    # The current accumelated sensor reading - this is owned by us
    var _sensor_accum: UnsafePointer[mut=True, Scalar[T]]
   
    # The state of the sensor of the camera (this data is copied to the window texture)
    var _sensor_state: UnsafePointer[mut=True, Scalar[T]]
    var _sensor_samples: Int

    var _dragging: Bool  # Is the camera moving/dragging (e.g. mouse is down state)
    var _last_x: Int32  # Last x position of the mouse
    var _last_y: Int32  # Last y position of the mouse

    fn __init__(
        out self,
    ) raises:
        # Set default field of view, starting position (look from), target (look at) and orientation (up vector)
        self._look_from = Point[Self.T, Self.dim](13, 2, 3)
        self._look_at = Point[Self.T, Self.dim](0, 0, 0)
        self._vup = Vec[Self.T, Self.dim](0, 1, 0)

        # Determine viewport dimensions
        self._focal_length = (self._look_from - self._look_at).length()
        var theta: Scalar[Self.T] = degrees_to_radians(fov)
        var h: Scalar[Self.T] = tan(theta / 2.0)
        self._viewport_height = 2.0 * h * self._focal_length
        self._viewport_width = self._viewport_height * (
            Scalar[Self.T](Self.width) / Scalar[Self.T](Self.height)
        )

        # Calculate the u,v,w basis vectors for the camera orientation. - TODO: somehow refactor the code to use update view matrix (however)
        var w = Vec.unit(self._look_from - self._look_at)
        var u = Vec.cross_3(self._vup, w)
        var v = Vec.cross_3(w, u)
        self._rot = Mat[Self.T, Self.dim](u, v, w)

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
        # self._defocus_angle = Scalar[Self.T](10.0) # Simulate a large aperature
        var defocus_radius = self._focal_length * tan(
            degrees_to_radians(aperature / 2)
        )
        self._defocus_disk_u = u * defocus_radius
        self._defocus_disk_v = v * defocus_radius

        self._sensor_accum = UnsafePointer[mut=True, Scalar[Self.T]].alloc(
            Self.height * Self.width * Self.channels
        )
        self._sensor_state = UnsafePointer[mut=True, Scalar[Self.T]].alloc(
            Self.height * Self.width * Self.channels
        )
        for i in range(Self.height * Self.width * Self.channels):
            (self._sensor_accum + i)[] = 0.0
            (self._sensor_state + i)[] = 1.0
        self._sensor_samples = 0

        # Initialize the dragging/movement state of the camera
        self._dragging = False
        self._last_x = 0
        self._last_y = 0

        # Do a final update of the view matrix: TODO: Remove the duplicate code above.
        self.update_view_matrix()

        print("Camera initialized")

    fn deinit(mut self):
        self._sensor_state.free()
        self._sensor_accum.free()
        print("Camera destroyed")

    fn update_view_matrix(
        mut self,
    ) raises -> None:
        self._rot[2] = (self._look_from - self._look_at).unit()
        self._rot[0] = Vec.cross_3(self._vup, self._rot[2]).unit()
        self._rot[1] = Vec.cross_3(self._rot[2], self._rot[0]).unit()

        var viewport_u = self._viewport_width * self._rot[0]
        var viewport_v = self._viewport_height * -self._rot[1]

        # Calculate the horizontal and vertical delta vectors from pixel to pixel.
        self._pixel_delta_u = viewport_u / Scalar[Self.T](Self.width)
        self._pixel_delta_v = viewport_v / Scalar[Self.T](Self.height)

        # Calculate the location of the upper left pixel.
        var viewport_upper_left = self._look_from - (
            self._focal_length * self._rot[2]
        ) - viewport_u / 2 - viewport_v / 2
        self._pixel00_loc = viewport_upper_left + 0.5 * (
            self._pixel_delta_u + self._pixel_delta_v
        )

    fn arcball(mut self, x: Int32, y: Int32) raises -> None:
        """
        Rotate the camera around the center of the scene.
        Attribution: https://asliceofrendering.com/camera/2019/11/30/ArcballCamera/.
        """
        if not self._dragging:
            return

        self._sensor_samples = 0  # Reset samples (so that sensor doesn't accumulate a blend of old/new positions)
        for i in range(Self.height * Self.width * Self.channels):
            (self._sensor_accum + i)[] = 0.0

        # Get the homogenous position of the camera and pivot point
        var position = Vec[Self.T, Self.dim](
            self._look_from[0], self._look_from[1], self._look_from[2]
        )
        var pivot = Vec[Self.T, Self.dim](
            self._look_at[0], self._look_at[1], self._look_at[2]
        )

        # Step 1 : Calculate the amount of rotation given the mouse movement.
        var delta_angle_x = 2 * Scalar[Self.T](pi) / Scalar[Self.T](Self.width)
        var delta_angle_y = Scalar[Self.T](pi) / Scalar[Self.T](Self.height)
        var x_angle = (self._last_x - x).cast[Self.T]() * -delta_angle_x
        var y_angle = (self._last_y - y).cast[Self.T]() * -delta_angle_y

        # Extra step to handle the problem when the camera direction is the same as the up vector
        var cos_angle = Vec.dot(self._rot[2], self._vup)
        if (
            cos_angle
            * (
                (Scalar[Self.T](0.0) < y_angle).cast[Self.T]()
                - (y_angle < Scalar[Self.T](0.0)).cast[Self.T]()
            )
        ) > 0.99:
            y_angle = 0

        # Step 2: Rotate the camera around the pivot point on the first axis.
        var rotation_matrix_x = Mat[Self.T, Self.dim].eye()
        rotation_matrix_x = Mat[Self.T, Self.dim].rotate_3(
            rotation_matrix_x, x_angle, self._vup
        )
        position = (rotation_matrix_x * (position - pivot)) + pivot

        # Step 3: Rotate the camera around the pivot point on the second axis.
        var rotation_matrix_y = Mat[Self.T, Self.dim].eye()
        rotation_matrix_y = Mat[Self.T, Self.dim].rotate_3(
            rotation_matrix_y, y_angle, self._rot[0]
        )
        var final_position = (rotation_matrix_y * (position - pivot)) + pivot

        # Update the camera view (we keep the same lookat and the same up vector)
        self._look_from = final_position
        self.update_view_matrix()

        # Update the mouse position for the next rotation
        self._last_x = x
        self._last_y = y

    fn start_dragging(mut self, x: Int32, y: Int32) -> None:
        self._last_x = x
        self._last_y = y
        self._dragging = True

    fn stop_dragging(mut self) -> None:
        self._dragging = False

    fn get_state(self) -> UnsafePointer[mut=True, Scalar[T]]:
        return self._sensor_state

    fn render(
        mut self,
        bvh_root : BVHNode[Self.T, Self.dim],
        compute_time_ms: Int64,
        redraw_time_ns: Int64,
        num_samples: Int = 1,
    ) raises:
        """
        Parallelize render, one row for each thread.
        TODO: Switch to one thread per pixel and compare performance (one we're running on GPU).
        """
        self._sensor_samples += 1

        # Don't render more than max_samples
        # Don't render more than max_samples
        if self._sensor_samples > max_samples:
            return

        # All captured references are unsafe references: https://docs.modular.com/mojo/roadmap#parameter-closure-captures-are-unsafe-references
        @parameter
        fn compute_row(y: Int):
            @parameter
            @parameter
            fn compute_row_vectorize[simd_width: Int](x: Int):
                # Send a ray into the scene from this x, y coordinate
                var rng = Rng(self._sensor_samples + (x << 24) + (y << 48))
                var pixel_samples_scale = 1.0 / Scalar[Self.T](num_samples)
                var pixel_color = Color4[Self.T](0, 0, 0, 0)
                for _ in range(num_samples):
                    var r = self.get_ray(rng, x, y)
                    pixel_color += Self._ray_color(
                        rng,
                        r,
                        max_depth,
                        bvh_root,
                        self.background
                    )
                pixel_color *= pixel_samples_scale.cast[Self.T]()

                # Progressively store the color in the render state
                var accum_scale = 1.0 / Scalar[Self.T](self._sensor_samples)
                var base_sensor_ptr = self._sensor_state + (y * (Self.width * Self.channels) + x * Self.channels)
                var base_accum_ptr = self._sensor_accum + (y * (Self.width * Self.channels) + x * Self.channels)
                @parameter
                for i in range(Self.channels):
                    (base_accum_ptr+i)[] += pixel_color[Self.channels - i - 1] * pixel_samples_scale
                    (base_sensor_ptr+i)[] = (base_accum_ptr + i)[] * accum_scale

            vectorize[compute_row_vectorize, 1](Self.width)

        parallelize[compute_row](Self.height, Self.height)

        # Some experimental code to render text to the texture
        var p = PIL()
        p.render_to_texture[Self.T](
            width,
            10,
            10,
            "average compute: " + String(compute_time_ms) + " ms",
        )
        p.render_to_texture(
            self._sensor_state,
            Self.width,
            10,
            25,
            "average redraw: " + String(redraw_time_ns) + " ns",
        )

    fn get_ray(self, mut rng : Rng, i: Int, j: Int) -> Ray[Self.T, Self.dim]:
        var offset = Self._sample_square(rng)

        var pixel_sample = self._pixel00_loc + (
            (Scalar[Self.T](i) + offset[0]) * self._pixel_delta_u
        ) + ((Scalar[Self.T](j) + offset[1]) * self._pixel_delta_v)

        var ray_origin = self._look_from if aperature <= 0.0 else self._defocus_disk_sample(rng)
        var ray_direction = pixel_sample - ray_origin
        var ray_time = rng.float64().cast[Self.T]()

        return Ray(ray_origin, ray_direction, ray_time)

    @staticmethod
    fn _sample_square(mut rng : Rng) -> Vec[T, dim]:
        """
        Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
        """
        return Vec[T, dim](
            rng.float64().cast[T]() - 0.5,
            rng.float64().cast[T]() - 0.5,
            0.0,
        )

    fn _defocus_disk_sample(self, mut rng : Rng) -> Point[Self.T, Self.dim]:
        """
        Returns a random point in the unit disk.
        """
        var p = Vec[Self.T, Self.dim].random_in_unit_disk(rng)
        return (
            self._look_from
            + self._defocus_disk_u * p[0]
            + self._defocus_disk_v * p[1]
        )

    @staticmethod
    @parameter
    fn _ray_color(
        mut rng : Rng,
        r: Ray[T, dim],
        depth: Int,
        bvh_root : BVHNode[T, dim],
        background : Color4[T]
    ) -> Color4[T]:
        """
        This is the first ECS 'system' like function that we're implementing in mo3d.
        """
        if depth <= 0:
            return Color4[T](0, 0, 0, 0)

        # BVH traversal
        var ray_t = Interval[T](0.001, inf[T]())
        var rec = HitRecord[T, dim]()
        var hit_anything = bvh_root.hit[T, dim](r, ray_t, rec)

        # If we hit something, scatter the ray and recurse
        if hit_anything:
            var scattered = Ray[T, dim]()
            var attenuation = Color4[T]()
            try:
                emitted = rec.mat.emission(rec)
                if rec.mat.scatter(rng, r, rec, attenuation, scattered):
                    return attenuation * Self._ray_color(
                        rng,
                        scattered,
                        depth - 1,
                        bvh_root,
                        background
                    ) + emitted
                return emitted
            except:
                pass
            return Color4[T](0, 0, 0, 0)

        return background
