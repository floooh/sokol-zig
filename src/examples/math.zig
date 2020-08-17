//------------------------------------------------------------------------------
//  math.zig
//
//  minimal vector math helper functions, just the stuff needed for
//  the sokol-samples
//------------------------------------------------------------------------------
const assert = @import("std").debug.assert;
const math = @import("std").math;

pub const Vec3 = packed struct {
    x: f32, y: f32, z: f32,

    pub fn zero() Vec3 {
        return Vec3 { .x=0.0, .y=0.0, .z=0.0 };
    }

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return Vec3 { .x=x, .y=y, .z=z };
    }
};

pub const Mat4 = packed struct {
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
    for (m.m) |row, y| {
        for (row) |val, x| {
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
    for (m.m) |row, y| {
        for (row) |val, x| {
            if (x == y) {
                assert(val == 1.0);
            }
            else {
                assert(val == 0.0);
            }
        }
    }
}

fn eq(val: f32, cmp: f32, delta: f32) bool {
    return (val > (cmp-delta)) and (val < (cmp+delta));
}

test "Mat4.persp" {
    const m = Mat4.persp(60.0, 1.33333337, 0.01, 10.0);

    assert(eq(m.m[0][0], 1.73205, 0.00001));
    assert(m.m[0][1] == 0.0);
    assert(m.m[0][2] == 0.0);
    assert(m.m[0][3] == 0.0);

    assert(m.m[1][0] == 0.0);
    assert(eq(m.m[1][1], 2.30940, 0.00001));
    assert(m.m[1][2] == 0.0);
    assert(m.m[1][3] == 0.0);

    assert(m.m[2][0] == 0.0);
    assert(m.m[2][1] == 0.0);
    assert(eq(m.m[2][2], -1.00200, 0.00001));
    assert(m.m[2][3] == -1.0);

    assert(m.m[3][0] == 0.0);
    assert(m.m[3][1] == 0.0);
    assert(eq(m.m[3][2], -0.02002, 0.00001));
    assert(m.m[3][3] == 0.0);
}




