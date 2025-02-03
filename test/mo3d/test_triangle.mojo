from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.geometry.triangle import Triangle
from mo3d.math.vec import Vec
from mo3d.math.mat import Mat
from mo3d.math.interval import Interval
from mo3d.ray.ray import Ray
from mo3d.ray.hit_record import HitRecord

alias f32 = DType.float32
alias Vec3 = Vec[f32, 3]

fn test_hit_triangle() raises:
    # Basic ray triangle hit in the plane
    var tri = Triangle[f32](
        Vec3(0, 0, 0),
        Vec3(1, 0, 0),
        Vec3(0, 1, 0)
    )

    var ray = Ray(Vec3(0.25,0.25,-1), Vec3(0,0,1))
    var ray_t = Interval[f32](0, 1000)
    var rec = HitRecord[f32, 3]()

    var res = tri.hit(ray, ray_t, rec)
    assert_true(res)
    assert_almost_equal(rec.t, 1, rtol = 1e-7)

    # Shift the scene by a ridgid transform and should still work
    var angles = List(Float32(0.0), Float32(3.14159 / 6.0), Float32(3.14159 / 3.0), Float32(3.14159 / 2.0))
    var positions = List(Vec3(0, 0, 0), Vec3(-100, 100, 0), Vec3(0, 0, 100))
    for angle_a in angles:
        for angle_b in angles:
            for pos in positions:
                var base = Mat[f32, 3].eye()
                var rotated_a = Mat[f32, 3].rotate_3(base, angle_a[], Vec3(1, 0 ,0))
                var m = Mat[f32, 3].rotate_3(rotated_a, angle_b[], Vec3(0, 0 ,1))
                var tri_rotated = Triangle[f32](
                    m * pos[],
                    m  * (pos[] + Vec3(1, 0, 0)),
                    m  * (pos[] + Vec3(0, 1, 0))
                )
                var ray_rotated = Ray(
                    m  * (pos[] + Vec3(0.25,0.25,-1)),
                    m * (Vec3(0,0,1))
                )

                var res = tri_rotated.hit(ray_rotated, ray_t, rec)
                assert_true(res)
                assert_almost_equal(rec.t, 1, rtol = 1e-5)


fn test_miss_triangle() raises:
    # Basic ray triangle hit in the plane
    var tri = Triangle[f32](
        Vec3(0, 0, 0),
        Vec3(1, 0, 0),
        Vec3(0, 1, 0)
    )

    var ray = Ray(Vec3(0.75,0.75,-1), Vec3(0,0,1))
    var ray_t = Interval[f32](0, 1000)
    var rec = HitRecord[f32, 3]()

    var res = tri.hit(ray, ray_t, rec)
    assert_false(res)

    # Shift the scene by a ridgid transform and should still work
    var angles = List(Float32(0.0), Float32(3.14159 / 6.0), Float32(3.14159 / 3.0), Float32(3.14159 / 2.0))
    var positions = List(Vec3(0, 0, 0), Vec3(-100, 100, 0), Vec3(0, 0, 100))
    for angle_a in angles:
        for angle_b in angles:
            for pos in positions:
                var base = Mat[f32, 3].eye()
                var rotated_a = Mat[f32, 3].rotate_3(base, angle_a[], Vec3(1, 0 ,0))
                var m = Mat[f32, 3].rotate_3(rotated_a, angle_b[], Vec3(0, 0 ,1))
                var tri_rotated = Triangle[f32](
                    m * pos[],
                    m  * (pos[] + Vec3(1, 0, 0)),
                    m  * (pos[] + Vec3(0, 1, 0))
                )
                var ray_rotated = Ray(
                    m  * (pos[] + Vec3(0.75,0.75,-1)),
                    m * (Vec3(0,0,1))
                )

                var res = tri_rotated.hit(ray_rotated, ray_t, rec)
                assert_false(res)
