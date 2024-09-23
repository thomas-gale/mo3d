from collections import InlineArray
from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.math.interval import Interval
from mo3d.math.vec import Vec
from mo3d.math.point import Point
from mo3d.ray.ray import Ray
from mo3d.geometry.aabb import AABB

alias ft = DType.float32


fn test_create_2d_aabb_from_bounds() raises:
    var bounds = InlineArray[Interval[ft, 1], 2](
        Interval[ft, 1](1, 2),
        Interval[ft, 1](2, 3),
    )

    var aabb = AABB[ft, 2](bounds)

    assert_equal(aabb._bounds[0].min, 1)
    assert_equal(aabb._bounds[0].max, 2)
    assert_equal(aabb._bounds[1].min, 2)
    assert_equal(aabb._bounds[1].max, 3)


fn test_create_3d_aabb_from_bounds() raises:
    var bounds = InlineArray[Interval[ft, 1], 3](
        Interval[ft, 1](1, 2),
        Interval[ft, 1](2, 3),
        Interval[ft, 1](0, 1),
    )

    var aabb = AABB[ft, 3](bounds)

    assert_equal(aabb._bounds[0].min, 1)
    assert_equal(aabb._bounds[0].max, 2)
    assert_equal(aabb._bounds[1].min, 2)
    assert_equal(aabb._bounds[1].max, 3)
    assert_equal(aabb._bounds[2].min, 0)
    assert_equal(aabb._bounds[2].max, 1)


fn test_create_3d_aabb_from_points() raises:
    var a = Point[ft, 3](1, 2, 3)
    var b = Point[ft, 3](4, 5, 6)

    var aabb = AABB[ft, 3](a, b)

    assert_equal(aabb._bounds[0].min, 1)
    assert_equal(aabb._bounds[0].max, 4)
    assert_equal(aabb._bounds[1].min, 2)
    assert_equal(aabb._bounds[1].max, 5)
    assert_equal(aabb._bounds[2].min, 3)
    assert_equal(aabb._bounds[2].max, 6)


fn test_3d_aabb_longest_axis() raises:
    var a = Point[ft, 3](1, 2, 3)
    var b = Point[ft, 3](2, 8, 4)

    var aabb = AABB[ft, 3](a, b)

    assert_equal(aabb.longest_axis(), 1)


fn test_hit_aabb() raises:
    var a = Point[ft, 3](-1, -1, -1)
    var b = Point[ft, 3](1, 1, 1)
    var aabb = AABB[ft, 3](a, b)

    var r = Ray[ft, 3](Point[ft, 3](0.0, 0.0, 5.0), Vec[ft, 3](0.0, 0.0, -1.0))
    var ray_t = Interval[ft](-10, 10)
    var hit = aabb.hit(r, ray_t)
    assert_true(hit)
