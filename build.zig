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
            const test_mod = bb.createModule(.{
                .root_source_file = bb.path(root),
                .target = t,
                .optimize = opt,
            });
            const test_exe = bb.addTest(.{
                .name = name,
                .root_module = test_mod,
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

    const core_memory_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/tests/memory_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const core_memory_tests = b.addTest(.{
        .name = "memory_test",
        .root_module = core_memory_tests_mod,
    });
    // Allow importing parent directory files by setting root to sdk/core
    core_memory_tests.root_module.addAnonymousImport("memory", .{
        .root_source_file = b.path("sdk/core/memory.zig"),
    });

    const core_time_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/tests/time_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const core_time_tests = b.addTest(.{
        .name = "time_test",
        .root_module = core_time_tests_mod,
    });
    core_time_tests.root_module.addAnonymousImport("time", .{
        .root_source_file = b.path("sdk/core/time.zig"),
    });

    const core_containers_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/tests/containers_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const core_containers_tests = b.addTest(.{
        .name = "containers_test",
        .root_module = core_containers_tests_mod,
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

    const core_crypto_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/tests/crypto_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const core_crypto_tests = b.addTest(.{
        .name = "crypto_test",
        .root_module = core_crypto_tests_mod,
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
    const core_event_store_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/tests/event_store_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const core_event_store_tests = b.addTest(.{
        .name = "event_store_test",
        .root_module = core_event_store_tests_mod,
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
    const domain_oms_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/oms_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_oms_tests = b.addTest(.{
        .name = "oms_test",
        .root_module = domain_oms_tests_mod,
    });
    domain_oms_tests.root_module.addImport("oms", oms_mod);

    // Domain tests: order_types
    const domain_order_types_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/order_types_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_order_types_tests = b.addTest(.{
        .name = "order_types_test",
        .root_module = domain_order_types_tests_mod,
    });
    domain_order_types_tests.root_module.addImport("order_types", order_types_mod);

    // Domain tests: risk/pre_trade
    const domain_risk_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/risk_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_risk_tests = b.addTest(.{
        .name = "risk_test",
        .root_module = domain_risk_tests_mod,
    });
    domain_risk_tests.root_module.addImport("pre_trade", pre_trade_mod);
    domain_risk_tests.root_module.addImport("oms", oms_mod);

    // Phase 8: positions tests
    const domain_positions_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/positions_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_positions_tests = b.addTest(.{
        .name = "positions_test",
        .root_module = domain_positions_tests_mod,
    });
    domain_positions_tests.root_module.addImport("positions", positions_mod);

    // Phase 8: VaR tests
    const domain_var_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/var_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_var_tests = b.addTest(.{
        .name = "var_test",
        .root_module = domain_var_tests_mod,
    });
    domain_var_tests.root_module.addImport("var", risk_var_mod);

    // Phase 8: greeks tests
    const domain_greeks_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/greeks_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_greeks_tests = b.addTest(.{
        .name = "greeks_test",
        .root_module = domain_greeks_tests_mod,
    });
    domain_greeks_tests.root_module.addImport("greeks", risk_greeks_mod);

    // Phase 11: post-trade modules
    const reconciliation_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/post_trade/reconciliation.zig"),
    });
    const eod_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/post_trade/eod.zig"),
    });
    eod_mod.addImport("reconciliation", reconciliation_mod);
    const allocation_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/post_trade/allocation.zig"),
    });
    allocation_mod.addImport("reconciliation", reconciliation_mod);

    // Phase 11: tick store + parquet modules
    const tick_store_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tick_store.zig"),
    });
    const parquet_writer_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/parquet_writer.zig"),
    });

    // Phase 11: reconciliation tests
    const domain_reconciliation_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/post_trade/tests/reconciliation_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_reconciliation_tests = b.addTest(.{
        .name = "reconciliation_test",
        .root_module = domain_reconciliation_tests_mod,
    });
    domain_reconciliation_tests.root_module.addImport("reconciliation", reconciliation_mod);

    // Phase 11: EOD tests
    const domain_eod_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/post_trade/tests/eod_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_eod_tests = b.addTest(.{
        .name = "eod_test",
        .root_module = domain_eod_tests_mod,
    });
    domain_eod_tests.root_module.addImport("eod", eod_mod);
    domain_eod_tests.root_module.addImport("reconciliation", reconciliation_mod);

    // Phase 11: allocation tests
    const domain_allocation_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/post_trade/tests/allocation_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_allocation_tests = b.addTest(.{
        .name = "allocation_test",
        .root_module = domain_allocation_tests_mod,
    });
    domain_allocation_tests.root_module.addImport("allocation", allocation_mod);

    // Phase 11: tick store tests
    const domain_tick_store_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/tick_store_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_tick_store_tests = b.addTest(.{
        .name = "tick_store_test",
        .root_module = domain_tick_store_tests_mod,
    });
    domain_tick_store_tests.root_module.addImport("tick_store", tick_store_mod);

    // Phase 11: parquet tests
    const domain_parquet_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/parquet_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_parquet_tests = b.addTest(.{
        .name = "parquet_test",
        .root_module = domain_parquet_tests_mod,
    });
    domain_parquet_tests.root_module.addImport("parquet_writer", parquet_writer_mod);

    // Phase 10: execution algorithm modules
    const twap_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/algos/twap.zig"),
    });
    const vwap_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/algos/vwap.zig"),
    });
    const pov_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/algos/pov.zig"),
    });
    const iceberg_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/algos/iceberg.zig"),
    });
    const sor_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/sor.zig"),
    });

    // Phase 10: TWAP tests
    const domain_twap_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/algos/tests/twap_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_twap_tests = b.addTest(.{
        .name = "twap_test",
        .root_module = domain_twap_tests_mod,
    });
    domain_twap_tests.root_module.addImport("twap", twap_mod);

    // Phase 10: VWAP tests
    const domain_vwap_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/algos/tests/vwap_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_vwap_tests = b.addTest(.{
        .name = "vwap_test",
        .root_module = domain_vwap_tests_mod,
    });
    domain_vwap_tests.root_module.addImport("vwap", vwap_mod);

    // Phase 10: POV tests
    const domain_pov_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/algos/tests/pov_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_pov_tests = b.addTest(.{
        .name = "pov_test",
        .root_module = domain_pov_tests_mod,
    });
    domain_pov_tests.root_module.addImport("pov", pov_mod);

    // Phase 10: Iceberg tests
    const domain_iceberg_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/algos/tests/iceberg_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_iceberg_tests = b.addTest(.{
        .name = "iceberg_test",
        .root_module = domain_iceberg_tests_mod,
    });
    domain_iceberg_tests.root_module.addImport("iceberg", iceberg_mod);

    // Phase 10: SOR tests
    const domain_sor_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/sor_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_sor_tests = b.addTest(.{
        .name = "sor_test",
        .root_module = domain_sor_tests_mod,
    });
    domain_sor_tests.root_module.addImport("sor", sor_mod);

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

    // Phase 11 run artifacts
    const run_reconciliation_tests = b.addRunArtifact(domain_reconciliation_tests);
    const run_eod_tests = b.addRunArtifact(domain_eod_tests);
    const run_allocation_tests = b.addRunArtifact(domain_allocation_tests);
    const run_tick_store_tests = b.addRunArtifact(domain_tick_store_tests);
    const run_parquet_tests = b.addRunArtifact(domain_parquet_tests);

    // Phase 10 run artifacts
    const run_twap_tests = b.addRunArtifact(domain_twap_tests);
    const run_vwap_tests = b.addRunArtifact(domain_vwap_tests);
    const run_pov_tests = b.addRunArtifact(domain_pov_tests);
    const run_iceberg_tests = b.addRunArtifact(domain_iceberg_tests);
    const run_sor_tests = b.addRunArtifact(domain_sor_tests);

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
    test_step.dependOn(&run_reconciliation_tests.step);
    test_step.dependOn(&run_eod_tests.step);
    test_step.dependOn(&run_allocation_tests.step);
    test_step.dependOn(&run_tick_store_tests.step);
    test_step.dependOn(&run_parquet_tests.step);
    test_step.dependOn(&run_twap_tests.step);
    test_step.dependOn(&run_vwap_tests.step);
    test_step.dependOn(&run_pov_tests.step);
    test_step.dependOn(&run_iceberg_tests.step);
    test_step.dependOn(&run_sor_tests.step);

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
    const proto_json_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tests/json_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const proto_json_tests = b.addTest(.{
        .name = "json_test",
        .root_module = proto_json_tests_mod,
    });
    proto_json_tests.root_module.addImport("json", json_mod);

    // TLS tests
    const proto_tls_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tests/tls_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const proto_tls_tests = b.addTest(.{
        .name = "tls_test",
        .root_module = proto_tls_tests_mod,
    });
    proto_tls_tests.root_module.addImport("record", tls_record_mod);
    proto_tls_tests.root_module.addImport("x509", x509_mod);
    proto_tls_tests.root_module.addImport("tls_client", tls_client_mod);

    // HTTP tests
    const proto_http_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tests/http_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const proto_http_tests = b.addTest(.{
        .name = "http_test",
        .root_module = proto_http_tests_mod,
    });
    proto_http_tests.root_module.addImport("url", http_url_mod);
    proto_http_tests.root_module.addImport("chunked", http_chunked_mod);
    proto_http_tests.root_module.addImport("http_client", http_client_mod);

    // ITCH tests
    const proto_itch_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tests/itch_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const proto_itch_tests = b.addTest(.{
        .name = "itch_test",
        .root_module = proto_itch_tests_mod,
    });
    proto_itch_tests.root_module.addAnonymousImport("itch", .{
        .root_source_file = b.path("sdk/protocol/itch.zig"),
    });

    // SBE tests
    const proto_sbe_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tests/sbe_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const proto_sbe_tests = b.addTest(.{
        .name = "sbe_test",
        .root_module = proto_sbe_tests_mod,
    });
    proto_sbe_tests.root_module.addAnonymousImport("sbe", .{
        .root_source_file = b.path("sdk/protocol/sbe.zig"),
    });

    // FAST tests
    const proto_fast_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tests/fast_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const proto_fast_tests = b.addTest(.{
        .name = "fast_test",
        .root_module = proto_fast_tests_mod,
    });
    proto_fast_tests.root_module.addAnonymousImport("fast", .{
        .root_source_file = b.path("sdk/protocol/fast.zig"),
    });

    // OUCH tests
    const proto_ouch_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tests/ouch_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const proto_ouch_tests = b.addTest(.{
        .name = "ouch_test",
        .root_module = proto_ouch_tests_mod,
    });
    proto_ouch_tests.root_module.addAnonymousImport("ouch", .{
        .root_source_file = b.path("sdk/protocol/ouch.zig"),
    });

    // PITCH tests
    const proto_pitch_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/tests/pitch_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const proto_pitch_tests = b.addTest(.{
        .name = "pitch_test",
        .root_module = proto_pitch_tests_mod,
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
    const fix_codec_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/fix/tests/codec_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const fix_codec_tests = b.addTest(.{
        .name = "fix_codec_test",
        .root_module = fix_codec_tests_mod,
    });
    fix_codec_tests.root_module.addImport("fix_codec", fix_codec_mod);

    // FIX session tests
    const fix_session_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/fix/tests/session_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const fix_session_tests = b.addTest(.{
        .name = "fix_session_test",
        .root_module = fix_session_tests_mod,
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
    const kraken_fix_client_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/tests/fix_client_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_fix_client_tests = b.addTest(.{
        .name = "kraken_fix_client_test",
        .root_module = kraken_fix_client_tests_mod,
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
    const ws_frame_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/protocol/websocket/tests/frame_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const ws_frame_tests = b.addTest(.{
        .name = "frame_test",
        .root_module = ws_frame_tests_mod,
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
    const kraken_spot_auth_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/tests/auth_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_spot_auth_tests = b.addTest(.{
        .name = "kraken_spot_auth_test",
        .root_module = kraken_spot_auth_tests_mod,
    });
    kraken_spot_auth_tests.root_module.addImport("spot_auth", spot_auth_mod);
    kraken_spot_auth_tests.root_module.addImport("base64", base64_mod);
    kraken_spot_auth_tests.root_module.addImport("hmac", hmac_mod);

    // Kraken spot rate limiter tests
    const kraken_spot_rate_limiter_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/tests/rate_limiter_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_spot_rate_limiter_tests = b.addTest(.{
        .name = "kraken_spot_rate_limiter_test",
        .root_module = kraken_spot_rate_limiter_tests_mod,
    });
    kraken_spot_rate_limiter_tests.root_module.addImport("spot_rate_limiter", spot_rate_limiter_mod);

    // Kraken spot rest_client tests
    const kraken_spot_rest_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/tests/rest_client_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_spot_rest_tests = b.addTest(.{
        .name = "kraken_spot_rest_test",
        .root_module = kraken_spot_rest_tests_mod,
    });
    kraken_spot_rest_tests.root_module.addImport("json", json_mod);

    // Kraken futures auth tests
    const kraken_futures_auth_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/tests/auth_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_futures_auth_tests = b.addTest(.{
        .name = "kraken_futures_auth_test",
        .root_module = kraken_futures_auth_tests_mod,
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

    // ---- Phase 12: Trading Strategies + Analytics ----

    const orderbook_mod_p12 = b.createModule(.{
        .root_source_file = b.path("sdk/domain/orderbook.zig"),
    });

    // Analytics modules
    const tca_mod = b.createModule(.{
        .root_source_file = b.path("trading/analytics/tca.zig"),
    });
    const attribution_mod = b.createModule(.{
        .root_source_file = b.path("trading/analytics/attribution.zig"),
    });
    const vpin_mod = b.createModule(.{
        .root_source_file = b.path("trading/analytics/vpin.zig"),
    });

    // Strategy modules
    const basis_mod = b.createModule(.{
        .root_source_file = b.path("trading/strategies/basis.zig"),
    });
    basis_mod.addImport("orderbook", orderbook_mod_p12);
    const funding_arb_mod = b.createModule(.{
        .root_source_file = b.path("trading/strategies/funding_arb.zig"),
    });
    funding_arb_mod.addImport("orderbook", orderbook_mod_p12);

    // TCA tests
    const tca_tests_mod = b.createModule(.{
        .root_source_file = b.path("trading/analytics/tests/tca_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const tca_tests = b.addTest(.{
        .name = "tca_test",
        .root_module = tca_tests_mod,
    });
    tca_tests.root_module.addImport("tca", tca_mod);

    // Attribution tests
    const attribution_tests_mod = b.createModule(.{
        .root_source_file = b.path("trading/analytics/tests/attribution_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const attribution_tests = b.addTest(.{
        .name = "attribution_test",
        .root_module = attribution_tests_mod,
    });
    attribution_tests.root_module.addImport("attribution", attribution_mod);

    // VPIN tests
    const vpin_tests_mod = b.createModule(.{
        .root_source_file = b.path("trading/analytics/tests/vpin_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const vpin_tests = b.addTest(.{
        .name = "vpin_test",
        .root_module = vpin_tests_mod,
    });
    vpin_tests.root_module.addImport("vpin", vpin_mod);

    // Basis strategy tests
    const basis_tests_mod = b.createModule(.{
        .root_source_file = b.path("trading/strategies/tests/basis_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const basis_tests = b.addTest(.{
        .name = "basis_test",
        .root_module = basis_tests_mod,
    });
    basis_tests.root_module.addImport("basis", basis_mod);
    basis_tests.root_module.addImport("orderbook", orderbook_mod_p12);

    // Funding arb tests
    const funding_arb_tests_mod = b.createModule(.{
        .root_source_file = b.path("trading/strategies/tests/funding_arb_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const funding_arb_tests = b.addTest(.{
        .name = "funding_arb_test",
        .root_module = funding_arb_tests_mod,
    });
    funding_arb_tests.root_module.addImport("funding_arb", funding_arb_mod);
    funding_arb_tests.root_module.addImport("orderbook", orderbook_mod_p12);

    const run_tca_tests = b.addRunArtifact(tca_tests);
    const run_attribution_tests = b.addRunArtifact(attribution_tests);
    const run_vpin_tests = b.addRunArtifact(vpin_tests);
    const run_basis_tests = b.addRunArtifact(basis_tests);
    const run_funding_arb_tests = b.addRunArtifact(funding_arb_tests);

    test_step.dependOn(&run_tca_tests.step);
    test_step.dependOn(&run_attribution_tests.step);
    test_step.dependOn(&run_vpin_tests.step);
    test_step.dependOn(&run_basis_tests.step);
    test_step.dependOn(&run_funding_arb_tests.step);

    // ---- Phase 4: WS clients + Market Data + Order Book ----

    // sdk/domain modules
    const orderbook_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/orderbook.zig"),
    });
    const orderbook_l3_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/orderbook_l3.zig"),
    });
    const bar_aggregator_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/bar_aggregator.zig"),
    });
    const market_data_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/market_data.zig"),
    });

    // Kraken spot WS client module
    const spot_ws_client_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/ws_client.zig"),
    });

    // Kraken futures WS client module
    const futures_ws_client_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/ws_client.zig"),
    });

    // orderbook tests (L2 + L3)
    const domain_orderbook_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/orderbook_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_orderbook_tests = b.addTest(.{
        .name = "orderbook_test",
        .root_module = domain_orderbook_tests_mod,
    });
    domain_orderbook_tests.root_module.addImport("orderbook", orderbook_mod);
    domain_orderbook_tests.root_module.addImport("orderbook_l3", orderbook_l3_mod);

    // bar_aggregator tests
    const domain_bar_aggregator_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/bar_aggregator_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_bar_aggregator_tests = b.addTest(.{
        .name = "bar_aggregator_test",
        .root_module = domain_bar_aggregator_tests_mod,
    });
    domain_bar_aggregator_tests.root_module.addImport("bar_aggregator", bar_aggregator_mod);

    // market_data tests
    const domain_market_data_tests_mod = b.createModule(.{
        .root_source_file = b.path("sdk/domain/tests/market_data_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const domain_market_data_tests = b.addTest(.{
        .name = "market_data_test",
        .root_module = domain_market_data_tests_mod,
    });
    domain_market_data_tests.root_module.addImport("market_data", market_data_mod);

    // Kraken spot WS client tests
    const kraken_spot_ws_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/tests/ws_client_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_spot_ws_tests = b.addTest(.{
        .name = "kraken_spot_ws_test",
        .root_module = kraken_spot_ws_tests_mod,
    });
    kraken_spot_ws_tests.root_module.addImport("spot_ws_client", spot_ws_client_mod);

    // Kraken futures WS client tests
    const kraken_futures_ws_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/tests/ws_client_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_futures_ws_tests = b.addTest(.{
        .name = "kraken_futures_ws_test",
        .root_module = kraken_futures_ws_tests_mod,
    });
    kraken_futures_ws_tests.root_module.addImport("futures_ws_client", futures_ws_client_mod);

    const run_domain_orderbook_tests = b.addRunArtifact(domain_orderbook_tests);
    const run_domain_bar_aggregator_tests = b.addRunArtifact(domain_bar_aggregator_tests);
    const run_domain_market_data_tests = b.addRunArtifact(domain_market_data_tests);
    const run_kraken_spot_ws_tests = b.addRunArtifact(kraken_spot_ws_tests);
    const run_kraken_futures_ws_tests = b.addRunArtifact(kraken_futures_ws_tests);

    test_step.dependOn(&run_domain_orderbook_tests.step);
    test_step.dependOn(&run_domain_bar_aggregator_tests.step);
    test_step.dependOn(&run_domain_market_data_tests.step);
    test_step.dependOn(&run_kraken_spot_ws_tests.step);
    test_step.dependOn(&run_kraken_futures_ws_tests.step);

    test_kraken_step.dependOn(&run_kraken_spot_ws_tests.step);
    test_kraken_step.dependOn(&run_kraken_futures_ws_tests.step);

    // ---- Phase 7: Kraken Order Execution End-to-End ----

    // Symbol translator module
    const symbol_translator_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/common/symbol_translator.zig"),
    });

    // Spot executor module
    const spot_executor_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/executor.zig"),
    });
    spot_executor_mod.addImport("oms", oms_mod);

    // Futures executor module
    const futures_executor_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/executor.zig"),
    });
    futures_executor_mod.addImport("oms", oms_mod);

    // Symbol translator tests
    const kraken_symbol_translator_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/common/tests/symbol_translator_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_symbol_translator_tests = b.addTest(.{
        .name = "kraken_symbol_translator_test",
        .root_module = kraken_symbol_translator_tests_mod,
    });
    kraken_symbol_translator_tests.root_module.addImport("symbol_translator", symbol_translator_mod);

    // Spot executor tests
    const kraken_spot_executor_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/spot/tests/executor_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_spot_executor_tests = b.addTest(.{
        .name = "kraken_spot_executor_test",
        .root_module = kraken_spot_executor_tests_mod,
    });
    kraken_spot_executor_tests.root_module.addImport("spot_executor", spot_executor_mod);
    kraken_spot_executor_tests.root_module.addImport("oms", oms_mod);
    // Note: order_types is NOT added here; the test accesses it via oms_mod re-exports
    // to avoid "file exists in multiple modules" when oms also imports order_types.

    // Futures executor tests
    const kraken_futures_executor_tests_mod = b.createModule(.{
        .root_source_file = b.path("exchanges/kraken/futures/tests/executor_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const kraken_futures_executor_tests = b.addTest(.{
        .name = "kraken_futures_executor_test",
        .root_module = kraken_futures_executor_tests_mod,
    });
    kraken_futures_executor_tests.root_module.addImport("futures_executor", futures_executor_mod);
    kraken_futures_executor_tests.root_module.addImport("oms", oms_mod);

    const run_kraken_symbol_translator_tests = b.addRunArtifact(kraken_symbol_translator_tests);
    const run_kraken_spot_executor_tests = b.addRunArtifact(kraken_spot_executor_tests);
    const run_kraken_futures_executor_tests = b.addRunArtifact(kraken_futures_executor_tests);

    test_step.dependOn(&run_kraken_symbol_translator_tests.step);
    test_step.dependOn(&run_kraken_spot_executor_tests.step);
    test_step.dependOn(&run_kraken_futures_executor_tests.step);

    test_kraken_step.dependOn(&run_kraken_symbol_translator_tests.step);
    test_kraken_step.dependOn(&run_kraken_spot_executor_tests.step);
    test_kraken_step.dependOn(&run_kraken_futures_executor_tests.step);

    // ---- Trading Desk TUI ----
    // Build steps: build-desk, run-desk, test-desk
    // Release builds: zig build build-desk -Doptimize=ReleaseFast

    // SDK core modules for desk (not yet modularized elsewhere)
    const memory_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/memory.zig"),
    });
    const time_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/time.zig"),
    });
    const ring_buffer_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/containers/ring_buffer.zig"),
    });
    const thread_mod = b.createModule(.{
        .root_source_file = b.path("sdk/core/io/thread.zig"),
    });
    _ = thread_mod;

    // Desk-specific strategy modules that use the same orderbook_mod instance as the desk build
    // to avoid "file exists in multiple modules" compilation errors.
    const basis_desk_mod = b.createModule(.{
        .root_source_file = b.path("trading/strategies/basis.zig"),
    });
    basis_desk_mod.addImport("orderbook", orderbook_mod);
    const funding_arb_desk_mod = b.createModule(.{
        .root_source_file = b.path("trading/strategies/funding_arb.zig"),
    });
    funding_arb_desk_mod.addImport("orderbook", orderbook_mod);

    // Desk main module (Zig 0.15: addExecutable requires root_module)
    const desk_main_mod = b.createModule(.{
        .root_source_file = b.path("trading/desk/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    desk_main_mod.addImport("orderbook", orderbook_mod);
    desk_main_mod.addImport("oms", oms_mod);
    desk_main_mod.addImport("order_types", order_types_mod);
    desk_main_mod.addImport("positions", positions_mod);
    desk_main_mod.addImport("pre_trade", pre_trade_mod);
    desk_main_mod.addImport("memory", memory_mod);
    desk_main_mod.addImport("time", time_mod);
    desk_main_mod.addImport("ring_buffer", ring_buffer_mod);
    desk_main_mod.addImport("bar_aggregator", bar_aggregator_mod);
    desk_main_mod.addImport("basis", basis_desk_mod);
    desk_main_mod.addImport("funding_arb", funding_arb_desk_mod);
    desk_main_mod.addImport("twap", twap_mod);
    desk_main_mod.addImport("vpin", vpin_mod);
    desk_main_mod.addImport("tca", tca_mod);
    desk_main_mod.addImport("eod", eod_mod);
    desk_main_mod.addImport("reconciliation", reconciliation_mod);

    // Desk TUI executable
    const desk_exe = b.addExecutable(.{
        .name = "desk-tui",
        .root_module = desk_main_mod,
    });
    b.installArtifact(desk_exe);

    // build-desk-tui step
    const build_desk_tui_step = b.step("build-desk-tui", "Build the Trading Desk TUI");
    build_desk_tui_step.dependOn(&desk_exe.step);

    // run-desk-tui step
    const run_desk = b.addRunArtifact(desk_exe);
    const run_desk_tui_step = b.step("run-desk-tui", "Run the Trading Desk TUI");
    run_desk_tui_step.dependOn(&run_desk.step);

    // test-desk-tui step (Zig 0.15: addTest requires root_module)
    const desk_test_mod = b.createModule(.{
        .root_source_file = b.path("trading/desk/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    desk_test_mod.addImport("orderbook", orderbook_mod);
    desk_test_mod.addImport("oms", oms_mod);
    desk_test_mod.addImport("order_types", order_types_mod);
    desk_test_mod.addImport("positions", positions_mod);
    desk_test_mod.addImport("pre_trade", pre_trade_mod);
    desk_test_mod.addImport("memory", memory_mod);
    desk_test_mod.addImport("time", time_mod);
    desk_test_mod.addImport("ring_buffer", ring_buffer_mod);
    desk_test_mod.addImport("bar_aggregator", bar_aggregator_mod);
    desk_test_mod.addImport("basis", basis_desk_mod);
    desk_test_mod.addImport("funding_arb", funding_arb_desk_mod);
    desk_test_mod.addImport("twap", twap_mod);
    desk_test_mod.addImport("vpin", vpin_mod);
    desk_test_mod.addImport("tca", tca_mod);
    desk_test_mod.addImport("eod", eod_mod);
    desk_test_mod.addImport("reconciliation", reconciliation_mod);
    const desk_tests = b.addTest(.{
        .name = "desk_tui_test",
        .root_module = desk_test_mod,
    });
    const run_desk_tests = b.addRunArtifact(desk_tests);
    const test_desk_tui_step = b.step("test-desk-tui", "Run Trading Desk TUI tests");
    test_desk_tui_step.dependOn(&run_desk_tests.step);

    // Backward-compat aliases for desk steps
    b.step("build-desk", "Build desk (alias for build-desk-tui)").dependOn(build_desk_tui_step);
    b.step("run-desk", "Run desk (alias for run-desk-tui)").dependOn(run_desk_tui_step);
    b.step("test-desk", "Run desk tests (alias for test-desk-tui)").dependOn(test_desk_tui_step);

    // ---- Trading Desk Headless ----
    // Headless executable: engine without terminal dependency, push/pop API.

    const headless_main_mod = b.createModule(.{
        .root_source_file = b.path("trading/desk/headless_main.zig"),
        .target = target,
        .optimize = optimize,
    });
    headless_main_mod.addImport("orderbook", orderbook_mod);
    headless_main_mod.addImport("oms", oms_mod);
    headless_main_mod.addImport("order_types", order_types_mod);
    headless_main_mod.addImport("positions", positions_mod);
    headless_main_mod.addImport("pre_trade", pre_trade_mod);
    headless_main_mod.addImport("memory", memory_mod);
    headless_main_mod.addImport("time", time_mod);
    headless_main_mod.addImport("ring_buffer", ring_buffer_mod);
    headless_main_mod.addImport("bar_aggregator", bar_aggregator_mod);
    headless_main_mod.addImport("basis", basis_desk_mod);
    headless_main_mod.addImport("funding_arb", funding_arb_desk_mod);
    headless_main_mod.addImport("twap", twap_mod);
    headless_main_mod.addImport("vpin", vpin_mod);
    headless_main_mod.addImport("tca", tca_mod);
    headless_main_mod.addImport("eod", eod_mod);
    headless_main_mod.addImport("reconciliation", reconciliation_mod);

    const desk_headless_exe = b.addExecutable(.{
        .name = "desk-headless",
        .root_module = headless_main_mod,
    });
    b.installArtifact(desk_headless_exe);

    // build-desk-headless step
    const build_desk_headless_step = b.step("build-desk-headless", "Build the Trading Desk Headless");
    build_desk_headless_step.dependOn(&desk_headless_exe.step);

    // run-desk-headless step
    const run_desk_headless = b.addRunArtifact(desk_headless_exe);
    const run_desk_headless_step = b.step("run-desk-headless", "Run the Trading Desk Headless");
    run_desk_headless_step.dependOn(&run_desk_headless.step);

    // test-desk-headless step
    const headless_test_mod = b.createModule(.{
        .root_source_file = b.path("trading/desk/headless_main.zig"),
        .target = target,
        .optimize = optimize,
    });
    headless_test_mod.addImport("orderbook", orderbook_mod);
    headless_test_mod.addImport("oms", oms_mod);
    headless_test_mod.addImport("order_types", order_types_mod);
    headless_test_mod.addImport("positions", positions_mod);
    headless_test_mod.addImport("pre_trade", pre_trade_mod);
    headless_test_mod.addImport("memory", memory_mod);
    headless_test_mod.addImport("time", time_mod);
    headless_test_mod.addImport("ring_buffer", ring_buffer_mod);
    headless_test_mod.addImport("bar_aggregator", bar_aggregator_mod);
    headless_test_mod.addImport("basis", basis_desk_mod);
    headless_test_mod.addImport("funding_arb", funding_arb_desk_mod);
    headless_test_mod.addImport("twap", twap_mod);
    headless_test_mod.addImport("vpin", vpin_mod);
    headless_test_mod.addImport("tca", tca_mod);
    headless_test_mod.addImport("eod", eod_mod);
    headless_test_mod.addImport("reconciliation", reconciliation_mod);
    const headless_tests = b.addTest(.{
        .name = "desk_headless_test",
        .root_module = headless_test_mod,
    });
    const run_headless_tests = b.addRunArtifact(headless_tests);
    const test_desk_headless_step = b.step("test-desk-headless", "Run Trading Desk Headless tests");
    test_desk_headless_step.dependOn(&run_headless_tests.step);

    // zcov: coverage analysis tool
    // Usage: zig build zcov [-- <module-filter>]
    // Builds the zcov executable, installs it to zig-out/bin/, and provides
    // a `zcov` build step that runs it.
    const zcov_mod = b.createModule(.{
        .root_source_file = b.path("test/zcov/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const zcov_exe = b.addExecutable(.{
        .name = "zcov",
        .root_module = zcov_mod,
    });
    b.installArtifact(zcov_exe);
    const zcov_run = b.addRunArtifact(zcov_exe);
    if (b.args) |run_args| zcov_run.addArgs(run_args);
    const zcov_step = b.step("zcov", "Run coverage analysis (compiles + runs tests with -ffuzz, reports line coverage)");
    zcov_step.dependOn(&zcov_run.step);
}
