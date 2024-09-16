from mo3d.math.interval import Interval
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord
from mo3d.ray.hittable import Hittable
from mo3d.geometry.aabb import AABB

struct BVHNode[T: DType, dim: Int](CollectionElement):	
  var _left: UnsafePointer[Hittable[T, dim]] # TODO: Non-owning pointer vs owning pointer - ECS refactor will help here
  var _right: UnsafePointer[Hittable[T, dim]] # TODO: Non-owning pointer vs owning pointer - ECS refactor will help here
  var _bbox: AABB[T, dim]

  fn __init__(inout self, owned objects: List[Hittable[T, dim]], start: Int, end: Int) raises:
    # self._left = UnsafePointer[Hittable[T, dim]]()  
    # self._right = UnsafePointer[Hittable[T, dim]]()
    # self._bbox = AABB[T, dim]()

    var object_span = end - start

    if object_span == 1:
      self._left = UnsafePointer[Hittable[T, dim]].address_of(objects[start])
      self._right = UnsafePointer[Hittable[T, dim]].address_of(objects[end])
    elif object_span == 2:
      self._left = UnsafePointer[Hittable[T, dim]].address_of(objects[start])
      self._right = UnsafePointer[Hittable[T, dim]].address_of(objects[start+1])
    else:
      @parameter
      fn cmp_fn(a: Hittable[T, dim], b: Hittable[T, dim]) -> Bool:
        # Just sort in x for now
        alias axis = 0
        return a.bounding_box()._bounds[axis].min < b.bounding_box()._bounds[axis].min
      sort[cmp_fn](objects)
      var mid = start + object_span // 2
      self._left = UnsafePointer[Hittable[T, dim]].alloc(1) # Ahh this will be owning...
      self._left[] = Hittable[T, dim](BVHNode[T, dim](objects, start, mid))
      self._right = UnsafePointer[Hittable[T, dim]].alloc(1) # Ahh this will be owning...
      self._right[] = Hittable[T, dim](BVHNode[T, dim](objects, mid, end))

    self._bbox = AABB[T, dim](self._left[].bounding_box(), self._right[].bounding_box())

  fn __copyinit__(inout self, other: Self):
    self._left = other._left
    self._right = other._right
    self._bbox = other._bbox  

  fn __moveinit__(inout self, owned other: Self):
    self._left = other._left
    self._right = other._right
    self._bbox = other._bbox  

  fn hit(
      self,
      r: Ray[T, dim],
      owned ray_t: Interval[T],
      inout rec: HitRecord[T, dim],
  ) -> Bool:
    if not self._bbox.hit(r, ray_t):
      return False

    var hit_left = self._left[].hit(r, ray_t, rec)
    var hit_right = self._right[].hit(r, Interval(ray_t.min, rec.t if hit_left else ray_t.max), rec)

    return hit_left or hit_right
