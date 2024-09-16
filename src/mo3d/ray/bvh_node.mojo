# class bvh_node : public hittable {
#   public:
#     bvh_node(hittable_list list) : bvh_node(list.objects, 0, list.objects.size()) {
#         // There's a C++ subtlety here. This constructor (without span indices) creates an
#         // implicit copy of the hittable list, which we will modify. The lifetime of the copied
#         // list only extends until this constructor exits. That's OK, because we only need to
#         // persist the resulting bounding volume hierarchy.
#     }

#     bvh_node(std::vector<shared_ptr<hittable>>& objects, size_t start, size_t end) {
#         // To be implemented later.
#     }

#     bool hit(const ray& r, interval ray_t, hit_record& rec) const override {
#         if (!bbox.hit(r, ray_t))
#             return false;

#         bool hit_left = left->hit(r, ray_t, rec);
#         bool hit_right = right->hit(r, interval(ray_t.min, hit_left ? rec.t : ray_t.max), rec);

#         return hit_left || hit_right;
#     }

#     aabb bounding_box() const override { return bbox; }

#   private:
#     shared_ptr<hittable> left;
#     shared_ptr<hittable> right;
#     aabb bbox;
# };

from random import random_ui64

from mo3d.ray.hittable import Hittable
from mo3d.geometry.aabb import AABB

struct BVHNode[T: DType, dim: Int]:	
  # var _left: Hittable[T, dim]
  # var _right: Hittable[T, dim]
  # var _bbox: AABB[T, dim]

  fn __init__(inout self, objects: List[Hittable[T, dim]], start: Int, end: Int):
      # int axis = random_int(0,2);

      # auto comparator = (axis == 0) ? box_x_compare
      #                 : (axis == 1) ? box_y_compare
      #                               : box_z_compare;

      # size_t object_span = end - start;

      # if (object_span == 1) {
      #     left = right = objects[start];
      # } else if (object_span == 2) {
      #     left = objects[start];
      #     right = objects[start+1];
      # } else {
      #     std::sort(std::begin(objects) + start, std::begin(objects) + end, comparator);

      #     auto mid = start + object_span/2;
      #     left = make_shared<bvh_node>(objects, start, mid);
      #     right = make_shared<bvh_node>(objects, mid, end);
      # }

      # bbox = aabb(left->bounding_box(), right->bounding_box());

      # var axis = random_ui64(0, 2)
      # var comparator = box_x_compare if axis == 0 else box_y_compare if axis == 1 else box_z_compare

  
