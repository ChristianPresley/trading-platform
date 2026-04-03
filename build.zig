const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Test step: run all tests
    const test_step = b.step("test", "Run all tests");
    const test_core_step = b.step("test-core", "Run sdk/core tests");

    // Helper to add a test executable and run it
    // We add the sdk/core directory as a module root so relative imports work.
    const addCoreTest = struct {
        fn add(
            bb: *std.Build,
            t: std.Build.ResolvedTarget,
            opt: std.builtin.OptimizeMode,
            name: []const u8,
            root: []const u8,
        ) *std.Build.Step.Compile {
            const test_exe = bb.addTest(.{
                .name = name,
                .root_source_file = bb.path(root),
                .target = t,
                .optimize = opt,
            });
            // Make sdk/core available as a module search path
            // In Zig 0.13, addAnonymousModule or addPath is the mechanism.
            // We expose the entire sdk/core tree by setting the module root.
            return test_exe;
        }
    }.add;

    // For Zig 0.13, the test root_source_file IS the module root.
    // Cross-directory imports with ".." are not allowed.
    // Solution: use a wrapper root file that lives in sdk/core/
    // and imports the implementation files using relative paths within the module.

    const core_memory_tests = b.addTest(.{
        .name = "memory_test",
        .root_source_file = b.path("sdk/core/tests/memory_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Allow importing parent directory files by setting root to sdk/core
    core_memory_tests.root_module.addAnonymousImport("memory", .{
        .root_source_file = b.path("sdk/core/memory.zig"),
    });

    const core_time_tests = b.addTest(.{
        .name = "time_test",
        .root_source_file = b.path("sdk/core/tests/time_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    core_time_tests.root_module.addAnonymousImport("time", .{
        .root_source_file = b.path("sdk/core/time.zig"),
    });

    const core_containers_tests = b.addTest(.{
        .name = "containers_test",
        .root_source_file = b.path("sdk/core/tests/containers_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    core_containers_tests.root_module.addAnonymousImport("ring_buffer", .{
        .root_source_file = b.path("sdk/core/containers/ring_buffer.zig"),
    });
    core_containers_tests.root_module.addAnonymousImport("mpsc_queue", .{
        .root_source_file = b.path("sdk/core/containers/mpsc_queue.zig"),
    });
    core_containers_tests.root_module.addAnonymousImport("hash_map", .{
        .root_source_file = b.path("sdk/core/containers/hash_map.zig"),
    });
    core_containers_tests.root_module.addAnonymousImport("sorted_array", .{
        .root_source_file = b.path("sdk/core/containers/sorted_array.zig"),
    });

    // Crypto modules
    const hmac_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/crypto/hmac.zig"),
    });
    const base64_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/crypto/base64.zig"),
    });
    const aes_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/crypto/aes.zig"),
    });
    const chacha20_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/crypto/chacha20.zig"),
    });
    const x25519_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/crypto/x25519.zig"),
    });
    const rsa_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/crypto/rsa.zig"),
    });
    const ecdsa_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/crypto/ecdsa.zig"),
    });

    const core_crypto_tests = b.addTest(.{
        .name = "crypto_test",
        .root_source_file = b.path("sdk/core/tests/crypto_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    core_crypto_tests.root_module.addImport("hmac", hmac_mod);
    core_crypto_tests.root_module.addImport("base64", base64_mod);
    core_crypto_tests.root_module.addImport("aes", aes_mod);
    core_crypto_tests.root_module.addImport("chacha20", chacha20_mod);
    core_crypto_tests.root_module.addImport("x25519", x25519_mod);
    core_crypto_tests.root_module.addImport("rsa", rsa_mod);
    core_crypto_tests.root_module.addImport("ecdsa", ecdsa_mod);

    _ = addCoreTest;

    // Event store tests (sdk/core)
    const core_event_store_tests = b.addTest(.{
        .name = "event_store_test",
        .root_source_file = b.path("sdk/core/tests/event_store_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    core_event_store_tests.root_module.addAnonymousImport("event_store", .{
        .root_source_file = b.path("sdk/core/event_store.zig"),
    });

    // Domain modules
    const order_types_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/order_types.zig"),
    });
    const oms_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/oms.zig"),
    });
    oms_mod.addImport("order_types", order_types_mod);

    const pre_trade_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/risk/pre_trade.zig"),
    });
    pre_trade_mod.addImport("oms", oms_mod);

    // Phase 8: positions, risk/math, risk/var, risk/greeks, risk/stress
    const positions_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/positions.zig"),
    });
    const risk_math_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/risk/math.zig"),
    });
    const risk_var_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/risk/var.zig"),
    });
    risk_var_mod.addImport("math", risk_math_mod);
    const risk_greeks_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/risk/greeks.zig"),
    });
    const risk_stress_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/risk/stress.zig"),
    });
    _ = risk_stress_mod;

    // Domain tests: OMS
    const domain_oms_tests = b.addTest(.{
        .name = "oms_test",
        .root_source_file = b.path("sdk/domain/tests/oms_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    domain_oms_tests.root_module.addImport("oms", oms_mod);

    // Domain tests: order_types
    const domain_order_types_tests = b.addTest(.{
        .name = "order_types_test",
        .root_source_file = b.path("sdk/domain/tests/order_types_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    domain_order_types_tests.root_module.addImport("order_types", order_types_mod);

    // Domain tests: risk/pre_trade
    const domain_risk_tests = b.addTest(.{
        .name = "risk_test",
        .root_source_file = b.path("sdk/domain/tests/risk_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    domain_risk_tests.root_module.addImport("pre_trade", pre_trade_mod);
    domain_risk_tests.root_module.addImport("oms", oms_mod);

    // Phase 8: positions tests
    const domain_positions_tests = b.addTest(.{
        .name = "positions_test",
        .root_source_file = b.path("sdk/domain/tests/positions_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    domain_positions_tests.root_module.addImport("positions", positions_mod);

    // Phase 8: VaR tests
    const domain_var_tests = b.addTest(.{
        .name = "var_test",
        .root_source_file = b.path("sdk/domain/tests/var_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    domain_var_tests.root_module.addImport("var", risk_var_mod);

    // Phase 8: greeks tests
    const domain_greeks_tests = b.addTest(.{
        .name = "greeks_test",
        .root_source_file = b.path("sdk/domain/tests/greeks_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    domain_greeks_tests.root_module.addImport("greeks", risk_greeks_mod);

    const run_memory_tests = b.addRunArtifact(core_memory_tests);
    const run_time_tests = b.addRunArtifact(core_time_tests);
    const run_containers_tests = b.addRunArtifact(core_containers_tests);
    const run_crypto_tests = b.addRunArtifact(core_crypto_tests);
    const run_event_store_tests = b.addRunArtifact(core_event_store_tests);
    const run_oms_tests = b.addRunArtifact(domain_oms_tests);
    const run_order_types_tests = b.addRunArtifact(domain_order_types_tests);
    const run_risk_tests = b.addRunArtifact(domain_risk_tests);
    const run_positions_tests = b.addRunArtifact(domain_positions_tests);
    const run_var_tests = b.addRunArtifact(domain_var_tests);
    const run_greeks_tests = b.addRunArtifact(domain_greeks_tests);

    test_step.dependOn(&run_memory_tests.step);
    test_step.dependOn(&run_time_tests.step);
    test_step.dependOn(&run_containers_tests.step);
    test_step.dependOn(&run_crypto_tests.step);
    test_step.dependOn(&run_event_store_tests.step);
    test_step.dependOn(&run_oms_tests.step);
    test_step.dependOn(&run_order_types_tests.step);
    test_step.dependOn(&run_risk_tests.step);
    test_step.dependOn(&run_positions_tests.step);
    test_step.dependOn(&run_var_tests.step);
    test_step.dependOn(&run_greeks_tests.step);

    test_core_step.dependOn(&run_memory_tests.step);
    test_core_step.dependOn(&run_time_tests.step);
    test_core_step.dependOn(&run_containers_tests.step);
    test_core_step.dependOn(&run_crypto_tests.step);
    test_core_step.dependOn(&run_event_store_tests.step);

    // ---- sdk/protocol tests ----
    const test_protocol_step = b.step("test-protocol", "Run sdk/protocol tests");

    // JSON module
    const json_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/json.zig"),
    });

    // TLS modules (names must match @import() calls in source files)
    const tls_record_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tls/record.zig"),
    });
    const x509_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tls/x509.zig"),
    });
    const tls_client_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tls/client.zig"),
    });
    tls_client_mod.addImport("record", tls_record_mod);
    tls_client_mod.addImport("x509", x509_mod);

    // HTTP modules
    const http_url_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/http/url.zig"),
    });
    const http_chunked_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/http/chunked.zig"),
    });
    const http_client_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/http/client.zig"),
    });
    http_client_mod.addImport("url", http_url_mod);
    http_client_mod.addImport("chunked", http_chunked_mod);

    // JSON tests
    const proto_json_tests = b.addTest(.{
        .name = "json_test",
        .root_source_file = b.path("sdk/protocol/tests/json_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_json_tests.root_module.addImport("json", json_mod);

    // TLS tests
    const proto_tls_tests = b.addTest(.{
        .name = "tls_test",
        .root_source_file = b.path("sdk/protocol/tests/tls_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_tls_tests.root_module.addImport("record", tls_record_mod);
    proto_tls_tests.root_module.addImport("x509", x509_mod);
    proto_tls_tests.root_module.addImport("tls_client", tls_client_mod);

    // HTTP tests
    const proto_http_tests = b.addTest(.{
        .name = "http_test",
        .root_source_file = b.path("sdk/protocol/tests/http_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_http_tests.root_module.addImport("url", http_url_mod);
    proto_http_tests.root_module.addImport("chunked", http_chunked_mod);
    proto_http_tests.root_module.addImport("http_client", http_client_mod);

    // ITCH tests
    const proto_itch_tests = b.addTest(.{
        .name = "itch_test",
        .root_source_file = b.path("sdk/protocol/tests/itch_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_itch_tests.root_module.addAnonymousImport("itch", .{
        .root_source_file = b.path("sdk/protocol/itch.zig"),
    });

    // SBE tests
    const proto_sbe_tests = b.addTest(.{
        .name = "sbe_test",
        .root_source_file = b.path("sdk/protocol/tests/sbe_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_sbe_tests.root_module.addAnonymousImport("sbe", .{
        .root_source_file = b.path("sdk/protocol/sbe.zig"),
    });

    // FAST tests
    const proto_fast_tests = b.addTest(.{
        .name = "fast_test",
        .root_source_file = b.path("sdk/protocol/tests/fast_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_fast_tests.root_module.addAnonymousImport("fast", .{
        .root_source_file = b.path("sdk/protocol/fast.zig"),
    });

    // OUCH tests
    const proto_ouch_tests = b.addTest(.{
        .name = "ouch_test",
        .root_source_file = b.path("sdk/protocol/tests/ouch_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_ouch_tests.root_module.addAnonymousImport("ouch", .{
        .root_source_file = b.path("sdk/protocol/ouch.zig"),
    });

    // PITCH tests
    const proto_pitch_tests = b.addTest(.{
        .name = "pitch_test",
        .root_source_file = b.path("sdk/protocol/tests/pitch_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_pitch_tests.root_module.addAnonymousImport("pitch", .{
        .root_source_file = b.path("sdk/protocol/pitch.zig"),
    });

    // FIX modules
    const fix_codec_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/fix/codec.zig"),
    });
    const fix_seq_store_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/fix/seq_store.zig"),
    });
    const fix_session_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/fix/session.zig"),
    });
    fix_session_mod.addImport("codec", fix_codec_mod);
    fix_session_mod.addImport("seq_store", fix_seq_store_mod);

    // FIX codec tests
    const fix_codec_tests = b.addTest(.{
        .name = "fix_codec_test",
        .root_source_file = b.path("sdk/protocol/fix/tests/codec_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    fix_codec_tests.root_module.addImport("fix_codec", fix_codec_mod);

    // FIX session tests
    const fix_session_tests = b.addTest(.{
        .name = "fix_session_test",
        .root_source_file = b.path("sdk/protocol/fix/tests/session_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    fix_session_tests.root_module.addImport("fix_codec", fix_codec_mod);
    fix_session_tests.root_module.addImport("fix_session", fix_session_mod);
    fix_session_tests.root_module.addImport("fix_seq_store", fix_seq_store_mod);

    // Kraken FIX client module
    const kraken_fix_client_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/fix_client.zig"),
    });
    kraken_fix_client_mod.addImport("fix_codec", fix_codec_mod);
    kraken_fix_client_mod.addImport("fix_session", fix_session_mod);
    kraken_fix_client_mod.addImport("hmac", hmac_mod);
    kraken_fix_client_mod.addImport("base64", base64_mod);

    // Kraken FIX client tests
    const kraken_fix_client_tests = b.addTest(.{
        .name = "kraken_fix_client_test",
        .root_source_file = b.path("exchanges/kraken/spot/tests/fix_client_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    kraken_fix_client_tests.root_module.addImport("fix_client", kraken_fix_client_mod);
    kraken_fix_client_tests.root_module.addImport("fix_codec", fix_codec_mod);

    const run_fix_codec_tests = b.addRunArtifact(fix_codec_tests);
    const run_fix_session_tests = b.addRunArtifact(fix_session_tests);
    const run_kraken_fix_client_tests = b.addRunArtifact(kraken_fix_client_tests);

    const run_proto_json_tests = b.addRunArtifact(proto_json_tests);
    const run_proto_tls_tests = b.addRunArtifact(proto_tls_tests);
    const run_proto_http_tests = b.addRunArtifact(proto_http_tests);
    const run_itch_tests = b.addRunArtifact(proto_itch_tests);
    const run_sbe_tests = b.addRunArtifact(proto_sbe_tests);
    const run_fast_tests = b.addRunArtifact(proto_fast_tests);
    const run_ouch_tests = b.addRunArtifact(proto_ouch_tests);
    const run_pitch_tests = b.addRunArtifact(proto_pitch_tests);

    test_step.dependOn(&run_proto_json_tests.step);
    test_step.dependOn(&run_proto_tls_tests.step);
    test_step.dependOn(&run_proto_http_tests.step);
    test_step.dependOn(&run_itch_tests.step);
    test_step.dependOn(&run_sbe_tests.step);
    test_step.dependOn(&run_fast_tests.step);
    test_step.dependOn(&run_ouch_tests.step);
    test_step.dependOn(&run_pitch_tests.step);
    test_step.dependOn(&run_fix_codec_tests.step);
    test_step.dependOn(&run_fix_session_tests.step);
    test_step.dependOn(&run_kraken_fix_client_tests.step);

    test_protocol_step.dependOn(&run_proto_json_tests.step);
    test_protocol_step.dependOn(&run_proto_tls_tests.step);
    test_protocol_step.dependOn(&run_proto_http_tests.step);
    test_protocol_step.dependOn(&run_itch_tests.step);
    test_protocol_step.dependOn(&run_sbe_tests.step);
    test_protocol_step.dependOn(&run_fast_tests.step);
    test_protocol_step.dependOn(&run_ouch_tests.step);
    test_protocol_step.dependOn(&run_pitch_tests.step);
    test_protocol_step.dependOn(&run_fix_codec_tests.step);
    test_protocol_step.dependOn(&run_fix_session_tests.step);

    // ---- Phase 3: WebSocket + Kraken REST ----
    const test_ws_step = b.step("test-ws", "Run WebSocket tests");
    const test_kraken_step = b.step("test-kraken", "Run Kraken exchange tests");

    // WebSocket frame module
    const ws_frame_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/websocket/frame.zig"),
    });

    // WebSocket frame tests
    const ws_frame_tests = b.addTest(.{
        .name = "frame_test",
        .root_source_file = b.path("sdk/protocol/websocket/tests/frame_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    ws_frame_tests.root_module.addImport("frame", ws_frame_mod);

    // Kraken spot auth module
    const spot_auth_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/auth.zig"),
    });
    spot_auth_mod.addImport("hmac", hmac_mod);
    spot_auth_mod.addImport("base64", base64_mod);

    // Kraken spot rate limiter module
    const spot_rate_limiter_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/rate_limiter.zig"),
    });

    // Kraken spot types module
    const spot_types_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/types.zig"),
    });

    // Kraken spot rest_client module
    const spot_rest_client_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/rest_client.zig"),
    });
    spot_rest_client_mod.addImport("http_client", http_client_mod);
    spot_rest_client_mod.addImport("json", json_mod);
    spot_rest_client_mod.addImport("spot_auth", spot_auth_mod);
    spot_rest_client_mod.addImport("spot_types", spot_types_mod);

    // Kraken futures auth module
    const futures_auth_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/auth.zig"),
    });
    futures_auth_mod.addImport("hmac", hmac_mod);
    futures_auth_mod.addImport("base64", base64_mod);

    // Kraken futures rate limiter module
    const futures_rate_limiter_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/rate_limiter.zig"),
    });
    _ = futures_rate_limiter_mod;

    // Kraken futures types module
    const futures_types_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/types.zig"),
    });

    // Kraken futures rest_client module
    const futures_rest_client_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/rest_client.zig"),
    });
    futures_rest_client_mod.addImport("http_client", http_client_mod);
    futures_rest_client_mod.addImport("json", json_mod);
    futures_rest_client_mod.addImport("futures_auth", futures_auth_mod);
    futures_rest_client_mod.addImport("futures_types", futures_types_mod);

    // Kraken spot auth tests
    const kraken_spot_auth_tests = b.addTest(.{
        .name = "kraken_spot_auth_test",
        .root_source_file = b.path("exchanges/kraken/spot/tests/auth_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    kraken_spot_auth_tests.root_module.addImport("spot_auth", spot_auth_mod);
    kraken_spot_auth_tests.root_module.addImport("base64", base64_mod);
    kraken_spot_auth_tests.root_module.addImport("hmac", hmac_mod);

    // Kraken spot rate limiter tests
    const kraken_spot_rate_limiter_tests = b.addTest(.{
        .name = "kraken_spot_rate_limiter_test",
        .root_source_file = b.path("exchanges/kraken/spot/tests/rate_limiter_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    kraken_spot_rate_limiter_tests.root_module.addImport("spot_rate_limiter", spot_rate_limiter_mod);

    // Kraken spot rest_client tests
    const kraken_spot_rest_tests = b.addTest(.{
        .name = "kraken_spot_rest_test",
        .root_source_file = b.path("exchanges/kraken/spot/tests/rest_client_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    kraken_spot_rest_tests.root_module.addImport("json", json_mod);

    // Kraken futures auth tests
    const kraken_futures_auth_tests = b.addTest(.{
        .name = "kraken_futures_auth_test",
        .root_source_file = b.path("exchanges/kraken/futures/tests/auth_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    kraken_futures_auth_tests.root_module.addImport("futures_auth", futures_auth_mod);
    kraken_futures_auth_tests.root_module.addImport("base64", base64_mod);
    kraken_futures_auth_tests.root_module.addImport("hmac", hmac_mod);

    const run_ws_frame_tests = b.addRunArtifact(ws_frame_tests);
    const run_kraken_spot_auth_tests = b.addRunArtifact(kraken_spot_auth_tests);
    const run_kraken_spot_rate_limiter_tests = b.addRunArtifact(kraken_spot_rate_limiter_tests);
    const run_kraken_spot_rest_tests = b.addRunArtifact(kraken_spot_rest_tests);
    const run_kraken_futures_auth_tests = b.addRunArtifact(kraken_futures_auth_tests);

    test_step.dependOn(&run_ws_frame_tests.step);
    test_step.dependOn(&run_kraken_spot_auth_tests.step);
    test_step.dependOn(&run_kraken_spot_rate_limiter_tests.step);
    test_step.dependOn(&run_kraken_spot_rest_tests.step);
    test_step.dependOn(&run_kraken_futures_auth_tests.step);

    test_ws_step.dependOn(&run_ws_frame_tests.step);

    test_kraken_step.dependOn(&run_kraken_spot_auth_tests.step);
    test_kraken_step.dependOn(&run_kraken_spot_rate_limiter_tests.step);
    test_kraken_step.dependOn(&run_kraken_spot_rest_tests.step);
    test_kraken_step.dependOn(&run_kraken_futures_auth_tests.step);
}
