const std = @import("std");
const c = @cImport({
    @cInclude("GLFW/glfw3.h");
    @cInclude("sokol_gfx.h");
});

pub fn main() void {
    _ = c.glfwInit();
    defer c.glfwTerminate();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 2);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GLFW_TRUE);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    var win = c.glfwCreateWindow(640, 480, c"Sokol Test", null, null);
    defer c.glfwDestroyWindow(win);
    c.glfwMakeContextCurrent(win);
    c.glfwSwapInterval(1);

    const desc = c.sg_desc { 0 };
    c.sg_setup(&desc);

    while (c.glfwWindowShouldClose(win) == c.GLFW_FALSE) {
        c.glfwSwapBuffers(win);
        c.glfwPollEvents();
    }
}
