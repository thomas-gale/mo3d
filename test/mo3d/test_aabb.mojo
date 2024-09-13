from testing import assert_true, assert_false, assert_equal, assert_almost_equal

# from mo3d.math.point import Point
# from mo3d.ecs.component_store import ComponentStore

from collections import InlineArray

from mo3d.math.interval import Interval
from mo3d.geometry.aabb import AABB

fn test_create_empty_aabb() raises:
    alias ft = DType.float32
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
