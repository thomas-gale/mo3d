from algorithm import parallelize, vectorize
from math import inf

from max.tensor import Tensor

from mo3d.precision import int_type, float_type
from mo3d.math.interval import Interval
from mo3d.math.vec4 import Vec4
from mo3d.math.point4 import Point4
from mo3d.ray.color4 import Color4
from mo3d.ray.ray4 import Ray4
from mo3d.ray.hittable_list import HittableList
from mo3d.ray.hittable import HitRecord


@value
struct Camera[width: Int, height: Int, channels: Int]:
    alias S4 = SIMD[float_type, 4]

    var _aspect_ratio: Scalar[float_type]  # Aspect ratio of the camera
    var _center: Point4[float_type]  # Camera center
    var _pixel00_loc: Point4[float_type]  # Location of pixel 0, 0
    var _pixel_delta_u: Vec4[float_type]  # Offset to pixel to the right
    var _pixel_delta_v: Vec4[float_type]  # Offset to pixel below

    fn __init__(
        inout self,
    ):
        # Calculate aspect ratio
        self._aspect_ratio = Scalar[float_type](width) / Scalar[float_type](
            height
        )

        # Set default camera center
        self._center = Point4(Self.S4(0, 0, 0, 1))

        # Determine viewport dimensions
        alias focal_length: Scalar[float_type] = 1.0
        alias viewport_height: Scalar[float_type] = 2.0
        var viewport_width: Scalar[
            float_type
        ] = viewport_height * self._aspect_ratio
        var camera_center = Vec4(Self.S4(0.0, 0.0, 0.0, 0.0))

        # Calculate the vectors across the horizontal and down the vertical viewport edges.
        var viewport_u = Vec4(Self.S4(viewport_width, 0.0, 0.0, 0.0))
        var viewport_v = Vec4(Self.S4(0.0, -1.0 * viewport_height, 0.0, 0.0))

        # Calculate the horizontal and vertical delta vectors from pixel to pixel.
        self._pixel_delta_u = viewport_u / Scalar[float_type](width)
        self._pixel_delta_v = viewport_v / Scalar[float_type](height)

        # Calculate the location of the upper left pixel.
        var viewport_upper_left = camera_center - Vec4(
            Self.S4(0, 0, focal_length, 0.0)
        ) - viewport_u / 2 - viewport_v / 2
        self._pixel00_loc = viewport_upper_left + 0.5 * (
            self._pixel_delta_u + self._pixel_delta_v
        )

    @staticmethod
    @parameter
    fn ray_color(
        r: Ray4[float_type], world: HittableList
    ) -> Color4[float_type]:
        """
        Sadly can't get the generic hittable trait as argument type to work :(.
        """
        var rec = HitRecord[float_type]()
        if world.hit(r, Interval[float_type](0.0, inf[float_type]()), rec):
            return 0.5 * (rec.normal + Vec4(Self.S4(1, 1, 1, 0)))

        var unit_direction = Vec4.unit(r.dir)
        var a = 0.5 * (unit_direction.y() + 1.0)
        return (1.0 - a) * Color4(Self.S4(1.0, 1.0, 1.0, 1.0)) + a * Color4(
            Self.S4(0.5, 0.7, 1.0, 1.0)
        )

    fn render(self, inout t: Tensor[float_type], world: HittableList):
        """
        Parallelize render, one row for each thread.
        """

        @parameter
        fn compute_row(y: Int):
            @parameter
            fn compute_row_vectorize[simd_width: Int](x: Int):
                # Send a ray into the scene from this x, y coordinate
                var pixel_center = self._pixel00_loc + (
                    x * self._pixel_delta_u
                ) + (y * self._pixel_delta_v)
                var ray_direction = pixel_center - self._center
                var r = Ray4(self._center, ray_direction)
                var pixel_color = Self.ray_color(r, world)

                t.store[4](
                    y * (width * channels) + x * channels,
                    SIMD[float_type, 4](
                        pixel_color.w(),  # A
                        pixel_color.z(),  # B
                        pixel_color.y(),  # G
                        pixel_color.x(),  # R
                        # 1.0,  # A
                        # 0.0,  # B
                        # (y / (height - 1)).cast[float_type](),  # G
                        # (x / (width - 1)).cast[float_type](),  # R
                    ),
                )

            vectorize[compute_row_vectorize, 1](width)

        # Inital values
        parallelize[compute_row](height, height)
