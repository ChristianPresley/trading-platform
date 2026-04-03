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

    const run_memory_tests = b.addRunArtifact(core_memory_tests);
    const run_time_tests = b.addRunArtifact(core_time_tests);
    const run_containers_tests = b.addRunArtifact(core_containers_tests);
    const run_crypto_tests = b.addRunArtifact(core_crypto_tests);
    const run_event_store_tests = b.addRunArtifact(core_event_store_tests);
    const run_oms_tests = b.addRunArtifact(domain_oms_tests);
    const run_order_types_tests = b.addRunArtifact(domain_order_types_tests);
    const run_risk_tests = b.addRunArtifact(domain_risk_tests);

    test_step.dependOn(&run_memory_tests.step);
    test_step.dependOn(&run_time_tests.step);
    test_step.dependOn(&run_containers_tests.step);
    test_step.dependOn(&run_crypto_tests.step);
    test_step.dependOn(&run_event_store_tests.step);
    test_step.dependOn(&run_oms_tests.step);
    test_step.dependOn(&run_order_types_tests.step);
    test_step.dependOn(&run_risk_tests.step);

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
    // tls_client.zig uses @import("record") and @import("x509")
    tls_client_mod.addImport("record", tls_record_mod);
    tls_client_mod.addImport("x509", x509_mod);

    // HTTP modules (names must match @import() calls in source files)
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

    // TLS tests (import names match @import() in tls_test.zig)
    const proto_tls_tests = b.addTest(.{
        .name = "tls_test",
        .root_source_file = b.path("sdk/protocol/tests/tls_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_tls_tests.root_module.addImport("record", tls_record_mod);
    proto_tls_tests.root_module.addImport("x509", x509_mod);
    proto_tls_tests.root_module.addImport("tls_client", tls_client_mod);

    // HTTP tests (import names match @import() in http_test.zig)
    const proto_http_tests = b.addTest(.{
        .name = "http_test",
        .root_source_file = b.path("sdk/protocol/tests/http_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    proto_http_tests.root_module.addImport("url", http_url_mod);
    proto_http_tests.root_module.addImport("chunked", http_chunked_mod);
    proto_http_tests.root_module.addImport("http_client", http_client_mod);

    const run_proto_json_tests = b.addRunArtifact(proto_json_tests);
    const run_proto_tls_tests = b.addRunArtifact(proto_tls_tests);
    const run_proto_http_tests = b.addRunArtifact(proto_http_tests);

    test_step.dependOn(&run_proto_json_tests.step);
    test_step.dependOn(&run_proto_tls_tests.step);
    test_step.dependOn(&run_proto_http_tests.step);

    test_protocol_step.dependOn(&run_proto_json_tests.step);
    test_protocol_step.dependOn(&run_proto_tls_tests.step);
    test_protocol_step.dependOn(&run_proto_http_tests.step);
}
