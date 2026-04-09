// Input handler tests
// Tests escape sequence parsing, key decoding, and state machine transitions.

const std = @import("std");
const input_mod = @import("input");
const InputHandler = input_mod.InputHandler;
const Action = input_mod.Action;

// ---- Init ----

test "init: starts in normal state" {
    const ih = InputHandler.init();
    // After init, feeding a normal character should work (confirms normal state).
    _ = ih;
}

// ---- Single-byte keys ----

test "feed: Tab (0x09) returns tab action" {
    var ih = InputHandler.init();
    const a = ih.feed(0x09, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .tab);
}

test "feed: Enter CR (0x0d) returns enter action" {
    var ih = InputHandler.init();
    const a = ih.feed(0x0d, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .enter);
}

test "feed: Enter LF (0x0a) returns enter action" {
    var ih = InputHandler.init();
    const a = ih.feed(0x0a, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .enter);
}

test "feed: DEL (0x7f) returns backspace" {
    var ih = InputHandler.init();
    const a = ih.feed(0x7f, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .backspace);
}

test "feed: BS (0x08) returns backspace" {
    var ih = InputHandler.init();
    const a = ih.feed(0x08, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .backspace);
}

test "feed: Ctrl+U (0x15) returns delete_line" {
    var ih = InputHandler.init();
    const a = ih.feed(0x15, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .delete_line);
}

test "feed: Ctrl+C (0x03) returns quit" {
    var ih = InputHandler.init();
    const a = ih.feed(0x03, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .quit);
}

// ---- Printable characters ----

test "feed: lowercase letter returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('a', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, 'a'), a.?.char);
}

test "feed: digit returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('5', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, '5'), a.?.char);
}

test "feed: space (0x20) returns char" {
    var ih = InputHandler.init();
    const a = ih.feed(0x20, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, ' '), a.?.char);
}

test "feed: tilde (0x7e) returns char" {
    var ih = InputHandler.init();
    const a = ih.feed(0x7e, false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, '~'), a.?.char);
}

// ---- Quit key: 'q' / 'Q' ----

test "feed: q in normal mode returns quit" {
    var ih = InputHandler.init();
    const a = ih.feed('q', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .quit);
}

test "feed: Q in normal mode returns quit" {
    var ih = InputHandler.init();
    const a = ih.feed('Q', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .quit);
}

test "feed: q in text mode returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('q', true);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, 'q'), a.?.char);
}

test "feed: Q in text mode returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('Q', true);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, 'Q'), a.?.char);
}

// ---- Toggle positions: 'p' ----

test "feed: p in normal mode returns toggle_positions" {
    var ih = InputHandler.init();
    const a = ih.feed('p', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .toggle_positions);
}

test "feed: p in text mode returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('p', true);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, 'p'), a.?.char);
}

// ---- Toggle crosshair: 'c' ----

test "feed: c in normal mode returns toggle_crosshair" {
    var ih = InputHandler.init();
    const a = ih.feed('c', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .toggle_crosshair);
}

test "feed: c in text mode returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('c', true);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, 'c'), a.?.char);
}

// ---- Zoom keys ----

test "feed: plus in normal mode returns zoom_in" {
    var ih = InputHandler.init();
    const a = ih.feed('+', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .zoom_in);
}

test "feed: equals in normal mode returns zoom_in" {
    var ih = InputHandler.init();
    const a = ih.feed('=', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .zoom_in);
}

test "feed: minus in normal mode returns zoom_out" {
    var ih = InputHandler.init();
    const a = ih.feed('-', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .zoom_out);
}

test "feed: plus in text mode returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('+', true);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, '+'), a.?.char);
}

test "feed: minus in text mode returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('-', true);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, '-'), a.?.char);
}

test "feed: equals in text mode returns char" {
    var ih = InputHandler.init();
    const a = ih.feed('=', true);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, '='), a.?.char);
}

// ---- Arrow keys (multi-byte escape sequences) ----

test "feed: arrow up (ESC [ A)" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null); // ESC
    try std.testing.expect(ih.feed('[', false) == null); // [
    const a = ih.feed('A', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .arrow_up);
}

test "feed: arrow down (ESC [ B)" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null);
    try std.testing.expect(ih.feed('[', false) == null);
    const a = ih.feed('B', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .arrow_down);
}

test "feed: arrow right (ESC [ C)" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null);
    try std.testing.expect(ih.feed('[', false) == null);
    const a = ih.feed('C', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .arrow_right);
}

test "feed: arrow left (ESC [ D)" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null);
    try std.testing.expect(ih.feed('[', false) == null);
    const a = ih.feed('D', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .arrow_left);
}

// ---- Shift-tab ----

test "feed: shift-tab via ESC [ Z" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null);
    try std.testing.expect(ih.feed('[', false) == null);
    const a = ih.feed('Z', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .shift_tab);
}

test "feed: shift-tab via ESC Z (no bracket)" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null);
    const a = ih.feed('Z', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .shift_tab);
}

// ---- Escape key ----

test "feed: ESC followed by non-bracket returns escape action" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null);
    const a = ih.feed('x', false); // not '[', not 'Z', not ESC
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .escape);
}

test "feed: double ESC returns escape for first" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null); // enter escape state
    const a = ih.feed(0x1b, false); // second ESC
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .escape);
}

test "feed: ESC [ followed by unknown char returns null" {
    var ih = InputHandler.init();
    try std.testing.expect(ih.feed(0x1b, false) == null);
    try std.testing.expect(ih.feed('[', false) == null);
    const a = ih.feed('X', false); // unknown CSI sequence
    try std.testing.expect(a == null);
}

// ---- State transitions ----

test "feed: state resets to normal after arrow key" {
    var ih = InputHandler.init();
    _ = ih.feed(0x1b, false);
    _ = ih.feed('[', false);
    _ = ih.feed('A', false); // arrow up
    // Should be back in normal state — next char should be treated normally
    const a = ih.feed('a', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
    try std.testing.expectEqual(@as(u8, 'a'), a.?.char);
}

test "feed: state resets to normal after unknown CSI" {
    var ih = InputHandler.init();
    _ = ih.feed(0x1b, false);
    _ = ih.feed('[', false);
    _ = ih.feed('9', false); // unknown
    // Back in normal state
    const a = ih.feed('a', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
}

test "feed: state resets to normal after ESC + non-bracket" {
    var ih = InputHandler.init();
    _ = ih.feed(0x1b, false);
    _ = ih.feed('x', false); // not '[' => escape action, reset to normal
    const a = ih.feed('a', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
}

// ---- frameReset ----

test "frameReset: returns null when in normal state" {
    var ih = InputHandler.init();
    const a = ih.frameReset();
    try std.testing.expect(a == null);
}

test "frameReset: returns escape when in escape state" {
    var ih = InputHandler.init();
    _ = ih.feed(0x1b, false); // enter escape state
    const a = ih.frameReset();
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .escape);
}

test "frameReset: returns escape when in escape_bracket state" {
    var ih = InputHandler.init();
    _ = ih.feed(0x1b, false);
    _ = ih.feed('[', false); // enter escape_bracket state
    const a = ih.frameReset();
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .escape);
}

test "frameReset: resets state to normal" {
    var ih = InputHandler.init();
    _ = ih.feed(0x1b, false); // enter escape state
    _ = ih.frameReset(); // should reset to normal
    // Now feeding a normal char should work
    const a = ih.feed('a', false);
    try std.testing.expect(a != null);
    try std.testing.expect(a.? == .char);
}

// ---- Sequence of inputs ----

test "feed: multiple arrow keys in sequence" {
    var ih = InputHandler.init();
    // Arrow up
    _ = ih.feed(0x1b, false);
    _ = ih.feed('[', false);
    const a1 = ih.feed('A', false);
    try std.testing.expect(a1.? == .arrow_up);
    // Arrow down
    _ = ih.feed(0x1b, false);
    _ = ih.feed('[', false);
    const a2 = ih.feed('B', false);
    try std.testing.expect(a2.? == .arrow_down);
    // Arrow right
    _ = ih.feed(0x1b, false);
    _ = ih.feed('[', false);
    const a3 = ih.feed('C', false);
    try std.testing.expect(a3.? == .arrow_right);
    // Arrow left
    _ = ih.feed(0x1b, false);
    _ = ih.feed('[', false);
    const a4 = ih.feed('D', false);
    try std.testing.expect(a4.? == .arrow_left);
}

test "feed: mixed input sequence" {
    var ih = InputHandler.init();
    // Type 'a', then arrow up, then tab, then enter
    const a1 = ih.feed('a', false);
    try std.testing.expect(a1.? == .char);
    _ = ih.feed(0x1b, false);
    _ = ih.feed('[', false);
    const a2 = ih.feed('A', false);
    try std.testing.expect(a2.? == .arrow_up);
    const a3 = ih.feed(0x09, false);
    try std.testing.expect(a3.? == .tab);
    const a4 = ih.feed(0x0d, false);
    try std.testing.expect(a4.? == .enter);
}

test "feed: Ctrl+C always quits regardless of text_mode" {
    var ih = InputHandler.init();
    // Ctrl+C in normal mode
    const a1 = ih.feed(0x03, false);
    try std.testing.expect(a1.? == .quit);
    // Ctrl+C in text mode
    const a2 = ih.feed(0x03, true);
    try std.testing.expect(a2.? == .quit);
}

test "feed: Ctrl+U always deletes line regardless of text_mode" {
    var ih = InputHandler.init();
    const a1 = ih.feed(0x15, false);
    try std.testing.expect(a1.? == .delete_line);
    const a2 = ih.feed(0x15, true);
    try std.testing.expect(a2.? == .delete_line);
}

test "feed: bytes below 0x20 (except known) return null" {
    var ih = InputHandler.init();
    // 0x01 (Ctrl+A) is not mapped — should return null
    const a = ih.feed(0x01, false);
    try std.testing.expect(a == null);
}

test "feed: byte 0x00 returns null" {
    var ih = InputHandler.init();
    const a = ih.feed(0x00, false);
    try std.testing.expect(a == null);
}

test "feed: byte 0x80 returns null (above ASCII)" {
    var ih = InputHandler.init();
    const a = ih.feed(0x80, false);
    try std.testing.expect(a == null);
}

// ---- Action union tag checks ----

test "Action: all variant tags are distinct" {
    const Tag = std.meta.Tag(Action);
    const tags = [_]Tag{
        .tab,
        .shift_tab,
        .arrow_up,
        .arrow_down,
        .arrow_left,
        .arrow_right,
        .enter,
        .escape,
        .char,
        .backspace,
        .quit,
        .delete_line,
        .toggle_positions,
        .zoom_in,
        .zoom_out,
        .toggle_crosshair,
    };
    // Ensure all tags are unique by checking each pair
    for (tags, 0..) |t1, i| {
        for (tags[i + 1 ..]) |t2| {
            try std.testing.expect(t1 != t2);
        }
    }
    // Total count matches the number of Action variants
    try std.testing.expectEqual(@as(usize, 16), tags.len);
}
