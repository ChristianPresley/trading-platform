const std = @import("std");
const codec = @import("codec");
const seq_store = @import("seq_store");

pub const FixVersion = enum {
    fix42,
    fix44,
    fix50sp2,

    pub fn toString(self: FixVersion) []const u8 {
        return switch (self) {
            .fix42 => "FIX.4.2",
            .fix44 => "FIX.4.4",
            .fix50sp2 => "FIXT.1.1",
        };
    }
};

pub const SessionConfig = struct {
    sender_comp_id: []const u8,
    target_comp_id: []const u8,
    fix_version: FixVersion,
    heartbeat_interval_s: u32,
};

pub const SessionState = enum {
    disconnected,
    connected,
    logged_on,
    logging_out,
};

/// FIX session layer (FIXT 1.1 compatible).
/// Handles sequence number management, admin message processing,
/// and session lifecycle (Logon/Logout/Heartbeat/TestRequest/ResendRequest/SequenceReset).
pub const FixSession = struct {
    allocator: std.mem.Allocator,
    config: SessionConfig,
    state: SessionState,
    next_send_seq: u32,
    next_recv_seq: u32,
    store: seq_store.SeqStore,

    /// Initializes sequence numbers to 1.
    pub fn init(allocator: std.mem.Allocator, config: SessionConfig) !FixSession {
        return .{
            .allocator = allocator,
            .config = config,
            .state = .disconnected,
            .next_send_seq = 1,
            .next_recv_seq = 1,
            .store = try seq_store.SeqStore.init(allocator),
        };
    }

    /// Connects TCP + TLS (stub — does not make real connections in this layer).
    pub fn connect(self: *FixSession, host: []const u8, port: u16) !void {
        _ = host;
        _ = port;
        self.state = .connected;
    }

    /// Builds a Logon(A) message and returns it for sending.
    /// The caller is responsible for deinit on the returned message.
    pub fn buildLogon(self: *FixSession) !codec.FixMessage {
        var msg = codec.FixMessage.init(self.allocator);
        try msg.setTag(8, self.config.fix_version.toString());
        try msg.setTag(35, "A"); // MsgType = Logon
        try msg.setTag(49, self.config.sender_comp_id);
        try msg.setTag(56, self.config.target_comp_id);
        var logon_seq_buf: [32]u8 = undefined;
        const logon_seq_str = try std.fmt.bufPrint(&logon_seq_buf, "{}", .{self.next_send_seq});
        try msg.setTag(34, logon_seq_str);
        try msg.setTag(52, "19700101-00:00:00"); // SendingTime placeholder
        try msg.setTag(98, "0"); // EncryptMethod = 0 (None)
        var hb_buf: [16]u8 = undefined;
        const hb_str = try std.fmt.bufPrint(&hb_buf, "{}", .{self.config.heartbeat_interval_s});
        try msg.setTag(108, hb_str); // HeartBtInt
        self.next_send_seq += 1;
        return msg;
    }

    /// Builds a Logout(5) message and returns it.
    pub fn buildLogout(self: *FixSession) !codec.FixMessage {
        var msg = codec.FixMessage.init(self.allocator);
        try msg.setTag(8, self.config.fix_version.toString());
        try msg.setTag(35, "5"); // MsgType = Logout
        try msg.setTag(49, self.config.sender_comp_id);
        try msg.setTag(56, self.config.target_comp_id);
        var logout_seq_buf: [32]u8 = undefined;
        const logout_seq_str = try std.fmt.bufPrint(&logout_seq_buf, "{}", .{self.next_send_seq});
        try msg.setTag(34, logout_seq_str);
        try msg.setTag(52, "19700101-00:00:00");
        self.next_send_seq += 1;
        return msg;
    }

    /// Sends a Logon message. In the unit-test model there is no real socket;
    /// the function advances internal state.
    pub fn logon(self: *FixSession) !void {
        var msg = try self.buildLogon();
        defer msg.deinit();
        var buf: [4096]u8 = undefined;
        _ = try msg.encode(&buf);
        self.state = .logged_on;
    }

    /// Applies standard header fields to a message (MsgSeqNum, SendingTime, SenderCompID, TargetCompID).
    /// Allocates the seq-num string — caller responsible for the message lifetime.
    pub fn prepareMessage(self: *FixSession, msg: *codec.FixMessage) !void {
        var seq_buf: [32]u8 = undefined;
        const seq_str = try std.fmt.bufPrint(&seq_buf, "{}", .{self.next_send_seq});
        try msg.setTag(8, self.config.fix_version.toString());
        try msg.setTag(34, seq_str); // MsgSeqNum
        try msg.setTag(52, "19700101-00:00:00"); // SendingTime
        try msg.setTag(49, self.config.sender_comp_id); // SenderCompID
        try msg.setTag(56, self.config.target_comp_id); // TargetCompID
    }

    /// Sets header fields and increments outbound sequence number.
    pub fn send(self: *FixSession, msg: *codec.FixMessage) !void {
        try self.prepareMessage(msg);
        var buf: [8192]u8 = undefined;
        const encoded = try msg.encode(&buf);
        // Store for potential resend
        try self.store.store(self.next_send_seq, encoded);
        self.next_send_seq += 1;
    }

    /// Processes an incoming decoded message.
    /// Handles admin messages (Heartbeat, TestRequest, SequenceReset, Logout) internally.
    /// Returns true if the message was an admin message handled internally,
    /// false if it should be forwarded to the application.
    pub fn processIncoming(self: *FixSession, msg: *codec.FixMessage) !bool {
        const msg_type = msg.getMsgType() orelse return error.MissingMsgType;

        // Validate sequence number
        const recv_seq_opt = msg.getInt(34);
        if (recv_seq_opt) |recv_seq| {
            if (recv_seq > 0) {
                const expected: i64 = @intCast(self.next_recv_seq);
                if (recv_seq > expected) {
                    // Gap detected — in production would send ResendRequest
                    // For the session layer we advance to avoid blocking
                    self.next_recv_seq = @intCast(recv_seq + 1);
                } else if (recv_seq == expected) {
                    self.next_recv_seq += 1;
                }
                // recv_seq < expected: possible duplicate, ignore
            }
        }

        if (std.mem.eql(u8, msg_type, "0")) {
            // Heartbeat — reset heartbeat timer (no-op in unit tests)
            return true;
        } else if (std.mem.eql(u8, msg_type, "1")) {
            // TestRequest — respond with Heartbeat containing TestReqID
            const test_req_id = msg.getTag(112) orelse "0";
            var hb = codec.FixMessage.init(self.allocator);
            defer hb.deinit();
            try hb.setTag(35, "0"); // Heartbeat
            try hb.setTag(112, test_req_id);
            try self.send(&hb);
            return true;
        } else if (std.mem.eql(u8, msg_type, "2")) {
            // ResendRequest — resend messages from store
            const begin_seq = msg.getInt(7) orelse 0;
            const end_seq = msg.getInt(16) orelse 0;
            var s: i64 = begin_seq;
            while (s <= end_seq or end_seq == 0) : (s += 1) {
                const stored = self.store.retrieve(@intCast(s));
                if (stored == null) break;
                // In a real implementation, retransmit via network
                if (end_seq == 0) break; // end_seq=0 means "through latest"
            }
            return true;
        } else if (std.mem.eql(u8, msg_type, "4")) {
            // SequenceReset — adjust expected sequence number
            const new_seq_no = msg.getInt(36) orelse return error.MissingNewSeqNo;
            self.next_recv_seq = @intCast(new_seq_no);
            return true;
        } else if (std.mem.eql(u8, msg_type, "5")) {
            // Logout — respond with Logout and mark session ended
            var logout_msg = try self.buildLogout();
            defer logout_msg.deinit();
            var buf: [4096]u8 = undefined;
            _ = try logout_msg.encode(&buf);
            self.state = .disconnected;
            return true;
        } else if (std.mem.eql(u8, msg_type, "A")) {
            // Logon response
            self.state = .logged_on;
            return true;
        }

        return false;
    }

    /// Sends a Logout message and marks session as logging out.
    pub fn logout(self: *FixSession) !void {
        self.state = .logging_out;
        var msg = try self.buildLogout();
        defer msg.deinit();
        var buf: [4096]u8 = undefined;
        _ = try msg.encode(&buf);
        self.state = .disconnected;
    }

    /// Frees all session resources.
    pub fn deinit(self: *FixSession) void {
        self.store.deinit();
    }
};
