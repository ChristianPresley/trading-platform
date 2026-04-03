const std = @import("std");

pub const Action = union(enum) {
    tab: void,
    shift_tab: void,
    arrow_up: void,
    arrow_down: void,
    arrow_left: void,
    arrow_right: void,
    enter: void,
    escape: void,
    char: u8,
    backspace: void,
    quit: void,
    delete_line: void,
};

const State = enum {
    normal,
    escape,
    escape_bracket,
};

pub const InputHandler = struct {
    state: State,
    timeout_frames: u8, // frames since entering escape state

    pub fn init() InputHandler {
        return InputHandler{
            .state = .normal,
            .timeout_frames = 0,
        };
    }

    /// Call once per frame if no bytes available, to timeout escape sequences.
    pub fn tickTimeout(self: *InputHandler) ?Action {
        if (self.state == .escape) {
            self.timeout_frames += 1;
            if (self.timeout_frames > 2) { // ~2 frames = ~130ms
                self.state = .normal;
                self.timeout_frames = 0;
                return .{ .escape = {} };
            }
        }
        return null;
    }

    /// Feed a byte from stdin. Returns an Action if a complete key sequence is recognized.
    pub fn feed(self: *InputHandler, byte: u8) ?Action {
        switch (self.state) {
            .normal => {
                return switch (byte) {
                    0x1b => { // ESC
                        self.state = .escape;
                        self.timeout_frames = 0;
                        return null;
                    },
                    0x03 => .{ .quit = {} }, // Ctrl+C
                    0x09 => .{ .tab = {} }, // Tab
                    0x0d => .{ .enter = {} }, // Enter
                    0x7f, 0x08 => .{ .backspace = {} }, // Backspace / DEL
                    0x15 => .{ .delete_line = {} }, // Ctrl+U
                    0x20...0x7e => .{ .char = byte }, // Printable ASCII
                    else => null,
                };
            },
            .escape => {
                self.timeout_frames = 0;
                if (byte == '[') {
                    self.state = .escape_bracket;
                    return null;
                } else {
                    self.state = .normal;
                    return .{ .escape = {} };
                }
            },
            .escape_bracket => {
                self.state = .normal;
                return switch (byte) {
                    'A' => .{ .arrow_up = {} },
                    'B' => .{ .arrow_down = {} },
                    'C' => .{ .arrow_right = {} },
                    'D' => .{ .arrow_left = {} },
                    'Z' => .{ .shift_tab = {} }, // Shift+Tab = ESC [ Z
                    else => null,
                };
            },
        }
    }
};

test "input_handler_basic_keys" {
    var handler = InputHandler.init();

    // Regular char
    const a = handler.feed('a');
    try std.testing.expect(a != null);
    switch (a.?) {
        .char => |c| try std.testing.expectEqual(@as(u8, 'a'), c),
        else => return error.TestUnexpectedResult,
    }

    // Enter
    const enter = handler.feed(0x0d);
    try std.testing.expect(enter != null);

    // Arrow key sequence: ESC [ A
    try std.testing.expect(handler.feed(0x1b) == null);
    try std.testing.expect(handler.feed('[') == null);
    const arrow = handler.feed('A');
    try std.testing.expect(arrow != null);
    switch (arrow.?) {
        .arrow_up => {},
        else => return error.TestUnexpectedResult,
    }
}
