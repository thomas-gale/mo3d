from algorithm import parallelize, vectorize
from math import inf, iota
from math.math import tan
from random import random_float64

from max.tensor import Tensor

from mo3d.precision import int_type, float_type
from mo3d.math.angle import degrees_to_radians
from mo3d.math.interval import Interval
from mo3d.math.vec4 import Vec4
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

    var _center: Point4[float_type]  # Camera center
    var _vfov: Scalar[float_type]  # Vertical field of view
    # var _look_from: Point4[float_type]  # Point camera is looking from
    # var _look_at: Point4[float_type]  # Point camera is looking at
    # var _vup: Vec4[float_type]  # Camera relative 'up' vector

    var _u: Vec4[float_type]  # Camera u vector
    var _v: Vec4[float_type]  # Camera v vector
    var _w: Vec4[float_type]  # Camera w vector

    var _pixel00_loc: Point4[float_type]  # Location of pixel 0, 0
    var _pixel_delta_u: Vec4[float_type]  # Offset to pixel to the right
    var _pixel_delta_v: Vec4[float_type]  # Offset to pixel below

    var _t: UnsafePointer[Scalar[float_type]]
    var _samples: Int

    fn __init__(
        inout self,
    ):
        # Set default camera center and field of view
        self._center = Point4(Self.S4(0, 0, 0, 0))
        self._vfov = Scalar[float_type](90.0)
        # self._look_from = Point4(Self.S4(0, 0, 0, 0))
        # self._look_at = Point4(Self.S4(0, 0, -1, 0))
        # self._vup = Vec4(Self.S4(0, 1, 0, 0))

        var look_from = Point4(Self.S4(0, 0, 0, 0))
        var look_at = Point4(Self.S4(0, 0, -1, 0))
        var vup = Vec4(Self.S4(0, 1, 0, 0))
        # var camera_center = self._look_from

        # Determine viewport dimensions
        alias focal_length: Scalar[float_type] = 1.0
        var theta: Scalar[float_type] = degrees_to_radians(self._vfov)
        var h: Scalar[float_type] = tan(theta / 2.0)
        var viewport_height: Scalar[float_type] = 2.0 * h * focal_length
        var viewport_width: Scalar[float_type] = viewport_height * (
            Scalar[float_type](width) / Scalar[float_type](height)
        )

        # Calculate the u,v,w basis vectors for the camera orientation. - TODO: somehow refactor the code to use update view matrix (however)
        self._w = Vec4.unit(look_from - look_at)
        self._u = Vec4.cross(vup, self._w)
        self._v = Vec4.cross(self._w, self._u)

        # Calculate the vectors across the horizontal and down the vertical viewport edges.
        var viewport_u = viewport_width * self._u
        var viewport_v = viewport_height * -self._v

        # Calculate the horizontal and vertical delta vectors from pixel to pixel.
        self._pixel_delta_u = viewport_u / Scalar[float_type](width)
        self._pixel_delta_v = viewport_v / Scalar[float_type](height)

        # Calculate the location of the upper left pixel.
        var viewport_upper_left = self._center - (
            focal_length * self._w
        ) - viewport_u / 2 - viewport_v / 2
        self._pixel00_loc = viewport_upper_left + 0.5 * (
            self._pixel_delta_u + self._pixel_delta_v
        )

        # Initialize the render state
        self._t = UnsafePointer[Scalar[float_type]].alloc(
            height * width * channels
        )
        for i in range(height * width * channels):
            (self._t + i)[] = 1.0

        self._samples = 0
        print("Camera initialized")

    fn __del__(owned self):
        self._t.free()
        print("Camera destroyed")

    fn update_view_matrix(
        inout self,
        look_from: Point4[float_type],
        look_at: Point4[float_type],
        vup: Vec4[float_type],
    ) -> None:
        self._w = Vec4.unit(look_from - look_at)
        self._u = Vec4.cross(vup, self._w)
        self._v = Vec4.cross(self._w, self._u)

    fn arcball(inout self) -> None:
        """
        Rotate the camera around the center of the scene.
        """
        pass

    fn get_state(self) -> UnsafePointer[Scalar[float_type]]:
        return self._t

    fn render(inout self, world: HittableList, num_samples: Int = 1):
        """
        Parallelize render, one row for each thread.
        TODO: Switch to one thread per pixel and compare performance (one we're running on GPU).
        """

        self._samples += 1
        if self._samples > max_samples:
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
                (self._t + (y * (width * channels) + x * channels))[] *= Scalar[
                    float_type
                ](self._samples - 1) / Scalar[float_type](self._samples)
                (
                    self._t + (y * (width * channels) + x * channels)
                )[] += pixel_color.w() / Scalar[float_type](self._samples)

                (
                    self._t + (y * (width * channels) + x * channels + 1)
                )[] *= Scalar[float_type](self._samples - 1) / Scalar[
                    float_type
                ](
                    self._samples
                )
                (
                    self._t + (y * (width * channels) + x * channels + 1)
                )[] += pixel_color.z() / Scalar[float_type](self._samples)

                (
                    self._t + (y * (width * channels) + x * channels + 2)
                )[] *= Scalar[float_type](self._samples - 1) / Scalar[
                    float_type
                ](
                    self._samples
                )
                (
                    self._t + (y * (width * channels) + x * channels + 2)
                )[] += pixel_color.y() / Scalar[float_type](self._samples)

                (
                    self._t + (y * (width * channels) + x * channels + 3)
                )[] *= Scalar[float_type](self._samples - 1) / Scalar[
                    float_type
                ](
                    self._samples
                )
                (
                    self._t + (y * (width * channels) + x * channels + 3)
                )[] += pixel_color.x() / Scalar[float_type](self._samples)

            vectorize[compute_row_vectorize, 1](width)

        parallelize[compute_row](height, height)

    fn get_ray(
        self, i: Scalar[int_type], j: Scalar[int_type]
    ) -> Ray4[float_type]:
        var offset = Self._sample_square()

        var pixel_sample = self._pixel00_loc + (
            (i.cast[float_type]() + offset.x()) * self._pixel_delta_u
        ) + ((j.cast[float_type]() + offset.y()) * self._pixel_delta_v)

        var ray_origin = self._center
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
