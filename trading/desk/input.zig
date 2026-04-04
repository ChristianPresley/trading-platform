// Input handler for Trading Desk TUI.
// Parses raw byte sequences into semantic Actions.

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
    toggle_positions: void,
    zoom_in: void,
    zoom_out: void,
};

const State = enum {
    normal,
    escape,
    escape_bracket,
};

pub const InputHandler = struct {
    state: State,
    seq_buf: [8]u8,
    seq_len: u8,

    pub fn init() InputHandler {
        return InputHandler{
            .state = .normal,
            .seq_buf = undefined,
            .seq_len = 0,
        };
    }

    /// Feed a byte from stdin. Returns an Action if one is complete, or null.
    /// In order entry mode (text_mode = true), 'q' is treated as a char, not quit.
    pub fn feed(self: *InputHandler, byte: u8, text_mode: bool) ?Action {
        switch (self.state) {
            .normal => {
                switch (byte) {
                    0x1b => { // ESC
                        self.state = .escape;
                        self.seq_len = 0;
                        return null;
                    },
                    0x09 => return Action{ .tab = {} }, // Tab
                    0x0d => return Action{ .enter = {} }, // Enter (CR)
                    0x0a => return Action{ .enter = {} }, // Enter (LF)
                    0x7f, 0x08 => return Action{ .backspace = {} }, // DEL / BS
                    0x15 => return Action{ .delete_line = {} }, // Ctrl+U
                    0x03 => return Action{ .quit = {} }, // Ctrl+C
                    0x20...0x7e => |c| {
                        // 'q' and 'Q' quit unless in text_mode
                        if ((c == 'q' or c == 'Q') and !text_mode) {
                            return Action{ .quit = {} };
                        }
                        // 'p' toggles positions overlay unless in text_mode
                        if (c == 'p' and !text_mode) {
                            return Action{ .toggle_positions = {} };
                        }
                        // '+' or '=' zooms in (= because + requires shift on US keyboards)
                        if ((c == '+' or c == '=') and !text_mode) {
                            return Action{ .zoom_in = {} };
                        }
                        // '-' zooms out
                        if (c == '-' and !text_mode) {
                            return Action{ .zoom_out = {} };
                        }
                        return Action{ .char = c };
                    },
                    else => return null,
                }
            },
            .escape => {
                if (byte == '[') {
                    self.state = .escape_bracket;
                    return null;
                } else if (byte == 0x1b) {
                    // Another ESC: emit escape for previous, start fresh
                    return Action{ .escape = {} };
                } else {
                    self.state = .normal;
                    // Check for shift-tab in some terminals: ESC + 'Z' without bracket
                    if (byte == 'Z') return Action{ .shift_tab = {} };
                    return Action{ .escape = {} };
                }
            },
            .escape_bracket => {
                self.state = .normal;
                return switch (byte) {
                    'A' => Action{ .arrow_up = {} },
                    'B' => Action{ .arrow_down = {} },
                    'C' => Action{ .arrow_right = {} },
                    'D' => Action{ .arrow_left = {} },
                    'Z' => Action{ .shift_tab = {} },
                    else => null,
                };
            },
        }
    }

    /// Call at frame boundary if in escape state (implicit timeout).
    pub fn frameReset(self: *InputHandler) ?Action {
        if (self.state != .normal) {
            self.state = .normal;
            return Action{ .escape = {} };
        }
        return null;
    }
};

test "input_handler_arrows" {
    const std = @import("std");
    var ih = InputHandler.init();
    // Arrow up: ESC [ A
    try std.testing.expect(ih.feed(0x1b, false) == null);
    try std.testing.expect(ih.feed('[', false) == null);
    const a = ih.feed('A', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .arrow_up);
}

test "input_handler_quit" {
    const std = @import("std");
    var ih = InputHandler.init();
    const a = ih.feed('q', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .quit);
}

test "input_handler_q_in_text_mode" {
    const std = @import("std");
    var ih = InputHandler.init();
    const a = ih.feed('q', true);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expect(a.?.char == 'q');
}
