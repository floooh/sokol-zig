//------------------------------------------------------------------------------
//  math.zig
//
//  minimal vector math helper functions, just the stuff needed for
//  the sokol-samples
//
//  Ported from HandmadeMath.h
//------------------------------------------------------------------------------
const assert = @import("std").debug.assert;
const math = @import("std").math;

fn radians(deg: f32) f32 {
    return deg * (math.pi / 180.0);
}

pub const Vec2 = extern struct {
    x: f32, y: f32,

    pub fn zero() Vec2 {
        return Vec2 { .x=0.0, .y=0.0 };
    }

    pub fn new(x: f32, y: f32) Vec2 {
        return Vec2 { .x=x, .y=y };
    }
};

pub const Vec3 = extern struct {
    x: f32, y: f32, z: f32,

    pub fn zero() Vec3 {
        return Vec3 { .x=0.0, .y=0.0, .z=0.0 };
    }

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return Vec3 { .x=x, .y=y, .z=z };
    }

    pub fn up() Vec3 {
        return Vec3 { .x=0.0, .y=1.0, .z=0.0 };
    }

    pub fn len(v: Vec3) f32 {
        return math.sqrt(Vec3.dot(v, v));
    }

    pub fn add(left: Vec3, right: Vec3) Vec3 {
        return Vec3 {
            .x = left.x + right.x,
            .y = left.y + right.y,
            .z = left.z + right.z
        };
    }

    pub fn sub(left: Vec3, right: Vec3) Vec3 {
        return Vec3 {
            .x = left.x - right.x,
            .y = left.y - right.y,
            .z = left.z - right.z
        };
    }

    pub fn mul(v: Vec3, s: f32) Vec3 {
        return Vec3 {
            .x = v.x * s,
            .y = v.y * s,
            .z = v.z * s
        };
    }

    pub fn norm(v: Vec3) Vec3 {
        const l = Vec3.len(v);
        if (l != 0.0) {
            return Vec3 {
                .x = v.x / l,
                .y = v.y / l,
                .z = v.z / l
            };
        }
        else {
            return Vec3.zero();
        }
    }

    pub fn cross(v0: Vec3, v1: Vec3) Vec3 {
        return Vec3 {
            .x = (v0.y * v1.z) - (v0.z * v1.y),
            .y = (v0.z * v1.x) - (v0.x * v1.z),
            .z = (v0.x * v1.y) - (v0.y * v1.x)
        };
    }

    pub fn dot(v0: Vec3, v1: Vec3) f32 {
        return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
    }
};

pub const Mat4 = extern struct {
    m: [4][4]f32,

    pub fn identity() Mat4 {
        return Mat4 {
            .m = [_][4]f32 {
                .{ 1.0, 0.0, 0.0, 0.0 },
                .{ 0.0, 1.0, 0.0, 0.0 },
                .{ 0.0, 0.0, 1.0, 0.0 },
                .{ 0.0, 0.0, 0.0, 1.0 }
            },
        };
    }

    pub fn zero() Mat4 {
        return Mat4 {
            .m = [_][4]f32 {
                .{ 0.0, 0.0, 0.0, 0.0 },
                .{ 0.0, 0.0, 0.0, 0.0 },
                .{ 0.0, 0.0, 0.0, 0.0 },
                .{ 0.0, 0.0, 0.0, 0.0 }
            },
        };
    }

    pub fn mul(left: Mat4, right: Mat4) Mat4 {
        var res = Mat4.zero();
        var col: usize = 0;
        while (col < 4): (col += 1) {
            var row: usize = 0;
            while (row < 4): (row += 1) {
                res.m[col][row] = left.m[0][row] * right.m[col][0] +
                                  left.m[1][row] * right.m[col][1] +
                                  left.m[2][row] * right.m[col][2] +
                                  left.m[3][row] * right.m[col][3];
            }
        }
        return res;
    }

    pub fn persp(fov: f32, aspect: f32, near: f32, far: f32) Mat4 {
        var res = Mat4.identity();
        const t = math.tan(fov * (math.pi / 360.0));
        res.m[0][0] = 1.0 / t;
        res.m[1][1] = aspect / t;
        res.m[2][3] = -1.0;
        res.m[2][2] = (near + far) / (near - far);
        res.m[3][2] = (2.0 * near * far) / (near - far);
        res.m[3][3] = 0.0;
        return res;
    }

    pub fn lookat(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
        var res = Mat4.zero();

        const f = Vec3.norm(Vec3.sub(center, eye));
        const s = Vec3.norm(Vec3.cross(f, up));
        const u = Vec3.cross(s, f);

        res.m[0][0] = s.x;
        res.m[0][1] = u.x;
        res.m[0][2] = -f.x;

        res.m[1][0] = s.y;
        res.m[1][1] = u.y;
        res.m[1][2] = -f.y;

        res.m[2][0] = s.z;
        res.m[2][1] = u.z;
        res.m[2][2] = -f.z;

        res.m[3][0] = -Vec3.dot(s, eye);
        res.m[3][1] = -Vec3.dot(u, eye);
        res.m[3][2] = Vec3.dot(f, eye);
        res.m[3][3] = 1.0;

        return res;
    }

    pub fn rotate(angle: f32, axis_unorm: Vec3) Mat4 {
        var res = Mat4.identity();

        const axis = Vec3.norm(axis_unorm);
        const sin_theta = math.sin(radians(angle));
        const cos_theta = math.cos(radians(angle));
        const cos_value = 1.0 - cos_theta;

        res.m[0][0] = (axis.x * axis.x * cos_value) + cos_theta;
        res.m[0][1] = (axis.x * axis.y * cos_value) + (axis.z * sin_theta);
        res.m[0][2] = (axis.x * axis.z * cos_value) - (axis.y * sin_theta);
        res.m[1][0] = (axis.y * axis.x * cos_value) - (axis.z * sin_theta);
        res.m[1][1] = (axis.y * axis.y * cos_value) + cos_theta;
        res.m[1][2] = (axis.y * axis.z * cos_value) + (axis.x * sin_theta);
        res.m[2][0] = (axis.z * axis.x * cos_value) + (axis.y * sin_theta);
        res.m[2][1] = (axis.z * axis.y * cos_value) - (axis.x * sin_theta);
        res.m[2][2] = (axis.z * axis.z * cos_value) + cos_theta;

        return res;
    }

    pub fn translate(translation: Vec3) Mat4 {
        var res = Mat4.identity();
        res.m[3][0] = translation.x;
        res.m[3][1] = translation.y;
        res.m[3][2] = translation.z;
        return res;
    }
};

test "Vec3.zero" {
    const v = Vec3.zero();
    assert(v.x == 0.0 and v.y == 0.0 and v.z == 0.0);
}

test "Vec3.new" {
    const v = Vec3.new(1.0, 2.0, 3.0);
    assert(v.x == 1.0 and v.y == 2.0 and v.z == 3.0);
}

test "Mat4.ident" {
    const m = Mat4.identity();
    for (m.m, 0..) |row, y| {
        for (row, 0..) |val, x| {
            if (x == y) {
                assert(val == 1.0);
            }
            else {
                assert(val == 0.0);
            }
        }
    }
}

test "Mat4.mul"{
    const l = Mat4.identity();
    const r = Mat4.identity();
    const m = Mat4.mul(l, r);
    for (m.m, 0..) |row, y| {
        for (row, 0..) |val, x| {
            if (x == y) {
                assert(val == 1.0);
            }
            else {
                assert(val == 0.0);
            }
        }
    }
}

fn eq(val: f32, cmp: f32) bool {
    const delta: f32 = 0.00001;
    return (val > (cmp-delta)) and (val < (cmp+delta));
}

test "Mat4.persp" {
    const m = Mat4.persp(60.0, 1.33333337, 0.01, 10.0);

    assert(eq(m.m[0][0], 1.73205));
    assert(eq(m.m[0][1], 0.0));
    assert(eq(m.m[0][2], 0.0));
    assert(eq(m.m[0][3], 0.0));

    assert(eq(m.m[1][0], 0.0));
    assert(eq(m.m[1][1], 2.30940));
    assert(eq(m.m[1][2], 0.0));
    assert(eq(m.m[1][3], 0.0));

    assert(eq(m.m[2][0], 0.0));
    assert(eq(m.m[2][1], 0.0));
    assert(eq(m.m[2][2], -1.00200));
    assert(eq(m.m[2][3], -1.0));

    assert(eq(m.m[3][0], 0.0));
    assert(eq(m.m[3][1], 0.0));
    assert(eq(m.m[3][2], -0.02002));
    assert(eq(m.m[3][3], 0.0));
}

test "Mat4.lookat" {
    const m = Mat4.lookat(.{ .x=0.0, .y=1.5, .z=6.0 }, Vec3.zero(), Vec3.up());

    assert(eq(m.m[0][0], 1.0));
    assert(eq(m.m[0][1], 0.0));
    assert(eq(m.m[0][2], 0.0));
    assert(eq(m.m[0][3], 0.0));

    assert(eq(m.m[1][0], 0.0));
    assert(eq(m.m[1][1], 0.97014));
    assert(eq(m.m[1][2], 0.24253));
    assert(eq(m.m[1][3], 0.0));

    assert(eq(m.m[2][0], 0.0));
    assert(eq(m.m[2][1], -0.24253));
    assert(eq(m.m[2][2], 0.97014));
    assert(eq(m.m[2][3], 0.0));

    assert(eq(m.m[3][0], 0.0));
    assert(eq(m.m[3][1], 0.0));
    assert(eq(m.m[3][2], -6.18465));
    assert(eq(m.m[3][3], 1.0));
}

test "Mat4.rotate" {
    const m = Mat4.rotate(2.0, .{ .x=0.0, .y=1.0, .z=0.0 });

    assert(eq(m.m[0][0], 0.99939));
    assert(eq(m.m[0][1], 0.0));
    assert(eq(m.m[0][2], -0.03489));
    assert(eq(m.m[0][3], 0.0));

    assert(eq(m.m[1][0], 0.0));
    assert(eq(m.m[1][1], 1.0));
    assert(eq(m.m[1][2], 0.0));
    assert(eq(m.m[1][3], 0.0));

    assert(eq(m.m[2][0], 0.03489));
    assert(eq(m.m[2][1], 0.0));
    assert(eq(m.m[2][2], 0.99939));
    assert(eq(m.m[2][3], 0.0));

    assert(eq(m.m[3][0], 0.0));
    assert(eq(m.m[3][1], 0.0));
    assert(eq(m.m[3][2], 0.0));
    assert(eq(m.m[3][3], 1.0));
}



