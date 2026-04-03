const std = @import("std");
const codec = @import("fix_codec");
const session_mod = @import("fix_session");
const seq_store_mod = @import("fix_seq_store");

fn makeConfig(sender: []const u8, target: []const u8) session_mod.SessionConfig {
    return .{
        .sender_comp_id = sender,
        .target_comp_id = target,
        .fix_version = .fix44,
        .heartbeat_interval_s = 30,
    };
}

// ---- SeqStore tests ----

test "SeqStore: init and deinit" {
    var store = try seq_store_mod.SeqStore.init(std.testing.allocator);
    defer store.deinit();
    try std.testing.expectEqual(@as(u32, 0), store.lastSeqNum());
}

test "SeqStore: store and retrieve" {
    var store = try seq_store_mod.SeqStore.init(std.testing.allocator);
    defer store.deinit();

    const msg = "8=FIX.4.2\x019=5\x0135=D\x0110=042\x01";
    try store.store(1, msg);
    const retrieved = store.retrieve(1);
    try std.testing.expect(retrieved != null);
    try std.testing.expectEqualStrings(msg, retrieved.?);
}

test "SeqStore: lastSeqNum" {
    var store = try seq_store_mod.SeqStore.init(std.testing.allocator);
    defer store.deinit();

    try store.store(1, "msg1");
    try store.store(3, "msg3");
    try store.store(2, "msg2");
    try std.testing.expectEqual(@as(u32, 3), store.lastSeqNum());
}

test "SeqStore: retrieve non-existent returns null" {
    var store = try seq_store_mod.SeqStore.init(std.testing.allocator);
    defer store.deinit();

    try std.testing.expect(store.retrieve(99) == null);
}

test "SeqStore: overwrite existing entry" {
    var store = try seq_store_mod.SeqStore.init(std.testing.allocator);
    defer store.deinit();

    try store.store(1, "original");
    try store.store(1, "updated");
    const r = store.retrieve(1);
    try std.testing.expect(r != null);
    try std.testing.expectEqualStrings("updated", r.?);
}

// ---- FixSession tests ----

test "FixSession: init state is disconnected" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("SENDER", "TARGET"));
    defer sess.deinit();

    try std.testing.expect(sess.state == .disconnected);
    try std.testing.expectEqual(@as(u32, 1), sess.next_send_seq);
    try std.testing.expectEqual(@as(u32, 1), sess.next_recv_seq);
}

test "FixSession: connect transitions to connected" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("SENDER", "TARGET"));
    defer sess.deinit();

    try sess.connect("localhost", 6881);
    try std.testing.expect(sess.state == .connected);
}

test "FixSession: buildLogon produces correct MsgType" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("MYSENDER", "MYTARGET"));
    defer sess.deinit();

    var logon_msg = try sess.buildLogon();
    defer logon_msg.deinit();

    try std.testing.expectEqualStrings("A", logon_msg.getMsgType().?);
    try std.testing.expectEqualStrings("MYSENDER", logon_msg.getTag(49).?);
    try std.testing.expectEqualStrings("MYTARGET", logon_msg.getTag(56).?);
    try std.testing.expectEqualStrings("0", logon_msg.getTag(98).?); // EncryptMethod=0
}

test "FixSession: logon increments sequence number" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();

    const seq_before = sess.next_send_seq;
    try sess.logon();
    try std.testing.expect(sess.next_send_seq > seq_before);
}

test "FixSession: logon transitions to logged_on" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();

    try sess.logon();
    try std.testing.expect(sess.state == .logged_on);
}

test "FixSession: send increments sequence number" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();
    try sess.logon();

    const seq_before = sess.next_send_seq;

    var msg = codec.FixMessage.init(std.testing.allocator);
    defer msg.deinit();
    try msg.setTag(35, "D");

    try sess.send(&msg);
    try std.testing.expect(sess.next_send_seq > seq_before);
}

test "FixSession: processIncoming Heartbeat is handled internally" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();
    try sess.logon();

    var hb = codec.FixMessage.init(std.testing.allocator);
    defer hb.deinit();
    try hb.setTag(8, "FIX.4.4");
    try hb.setTag(35, "0"); // Heartbeat
    try hb.setTag(34, "1");

    const handled = try sess.processIncoming(&hb);
    try std.testing.expect(handled == true);
}

test "FixSession: processIncoming Logon response sets logged_on" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();
    sess.state = .connected;

    var logon_resp = codec.FixMessage.init(std.testing.allocator);
    defer logon_resp.deinit();
    try logon_resp.setTag(8, "FIX.4.4");
    try logon_resp.setTag(35, "A");
    try logon_resp.setTag(34, "1");

    const handled = try sess.processIncoming(&logon_resp);
    try std.testing.expect(handled == true);
    try std.testing.expect(sess.state == .logged_on);
}

test "FixSession: processIncoming SequenceReset adjusts recv seq" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();
    try sess.logon();

    var sr = codec.FixMessage.init(std.testing.allocator);
    defer sr.deinit();
    try sr.setTag(8, "FIX.4.4");
    try sr.setTag(35, "4"); // SequenceReset
    try sr.setTag(34, "1");
    try sr.setTag(36, "10"); // NewSeqNo

    const handled = try sess.processIncoming(&sr);
    try std.testing.expect(handled == true);
    try std.testing.expectEqual(@as(u32, 10), sess.next_recv_seq);
}

test "FixSession: processIncoming Logout disconnects" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();
    try sess.logon();

    var logout = codec.FixMessage.init(std.testing.allocator);
    defer logout.deinit();
    try logout.setTag(8, "FIX.4.4");
    try logout.setTag(35, "5"); // Logout
    try logout.setTag(34, "1");

    const handled = try sess.processIncoming(&logout);
    try std.testing.expect(handled == true);
    try std.testing.expect(sess.state == .disconnected);
}

test "FixSession: processIncoming application message returns false" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();
    try sess.logon();

    var exec_rpt = codec.FixMessage.init(std.testing.allocator);
    defer exec_rpt.deinit();
    try exec_rpt.setTag(8, "FIX.4.4");
    try exec_rpt.setTag(35, "8"); // ExecutionReport
    try exec_rpt.setTag(34, "1");

    const handled = try sess.processIncoming(&exec_rpt);
    try std.testing.expect(handled == false);
}

test "FixSession: logout transitions to disconnected" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();
    try sess.logon();

    try sess.logout();
    try std.testing.expect(sess.state == .disconnected);
}

test "FixSession: buildLogon uses correct FIX version string" {
    const config_42 = session_mod.SessionConfig{
        .sender_comp_id = "S",
        .target_comp_id = "T",
        .fix_version = .fix42,
        .heartbeat_interval_s = 30,
    };
    var sess = try session_mod.FixSession.init(std.testing.allocator, config_42);
    defer sess.deinit();

    var logon_msg = try sess.buildLogon();
    defer logon_msg.deinit();

    try std.testing.expectEqualStrings("FIX.4.2", logon_msg.getTag(8).?);
}

test "FixSession: sequence number increments across sends" {
    var sess = try session_mod.FixSession.init(std.testing.allocator, makeConfig("S", "T"));
    defer sess.deinit();
    try sess.logon();

    const after_logon = sess.next_send_seq;

    var msg1 = codec.FixMessage.init(std.testing.allocator);
    defer msg1.deinit();
    try msg1.setTag(35, "D");
    try sess.send(&msg1);

    var msg2 = codec.FixMessage.init(std.testing.allocator);
    defer msg2.deinit();
    try msg2.setTag(35, "D");
    try sess.send(&msg2);

    try std.testing.expectEqual(after_logon + 2, sess.next_send_seq);
}
