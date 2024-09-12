from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.ecs.component_store import ComponentStore


fn test_create_empty_component_store() raises:
    var store = ComponentStore[DType.float32, 3]()
