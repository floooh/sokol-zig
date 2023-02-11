//------------------------------------------------------------------------------
//  debugtext.zig
//
//  Basic test and demo for the sokol.debugtext module
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog  = sokol.log;
const sg    = sokol.gfx;
const sapp  = sokol.app;
const sgapp = sokol.app_gfx_glue;
const sdtx  = sokol.debugtext;

// font indices
const KC853 = 0;
const KC854 = 1;
const Z1013 = 2;
const CPC   = 3;
const C64   = 4;
const ORIC  = 5;

var pass_action: sg.PassAction = .{};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
        .logger = .{ .func = slog.func },
    });

    // setup sokol-debugtext with all builtin fonts
    var sdtx_desc: sdtx.Desc = .{ .logger = .{ .func = slog.func } };
    sdtx_desc.fonts[KC853] = sdtx.fontKc853();
    sdtx_desc.fonts[KC854] = sdtx.fontKc854();
    sdtx_desc.fonts[Z1013] = sdtx.fontZ1013();
    sdtx_desc.fonts[CPC]   = sdtx.fontCpc();
    sdtx_desc.fonts[C64]   = sdtx.fontC64();
    sdtx_desc.fonts[ORIC]  = sdtx.fontOric();
    sdtx.setup(sdtx_desc);

    pass_action.colors[0] = .{ .action = .CLEAR, .value = .{ .r=0, .g=0.125, .b=0.25, .a=1 }};
}

// print all characters in a font
fn printFont(font_index: u32, title: [:0]const u8, r: u8, g: u8, b: u8) void {
    sdtx.font(font_index);
    sdtx.color3b(r, g, b);
    sdtx.puts(title);
    var c: u16 = 32;
    while (c < 256): (c += 1) {
        sdtx.putc(@intCast(u8, c));
        if (((c + 1) & 63) == 0) {
            sdtx.crlf();
        }
    }
    sdtx.crlf();
}

export fn frame() void {
    // set virtual canvas size to half display size so that
    // glyphs are 16x16 display pixels
    sdtx.canvas(sapp.widthf()*0.5, sapp.heightf()*0.5);
    sdtx.origin(0.0, 2.0);
    sdtx.home();

    // draw all font characters
    printFont(KC853, "KC85/3:\n",      0xf4, 0x43, 0x36);
    printFont(KC854, "KC85/4:\n",      0x21, 0x96, 0xf3);
    printFont(Z1013, "Z1013:\n",       0x4c, 0xaf, 0x50);
    printFont(CPC,   "Amstrad CPC:\n", 0xff, 0xeb, 0x3b);
    printFont(C64,   "C64:\n",         0x79, 0x86, 0xcb);
    printFont(ORIC,  "Oric Atmos:\n",  0xff, 0x98, 0x00);

    // do the actual rendering
    sg.beginDefaultPass(pass_action, sapp.width(), sapp.height());
    sdtx.draw();
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sdtx.shutdown();
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 1024,
        .height = 600,
        .icon = .{ .sokol_default = true },
        .window_title = "debugtext.zig",
        .logger = .{ .func = slog.func },
    });
}
