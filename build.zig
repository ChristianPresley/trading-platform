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

    const run_memory_tests = b.addRunArtifact(core_memory_tests);
    const run_time_tests = b.addRunArtifact(core_time_tests);
    const run_containers_tests = b.addRunArtifact(core_containers_tests);
    const run_crypto_tests = b.addRunArtifact(core_crypto_tests);

    test_step.dependOn(&run_memory_tests.step);
    test_step.dependOn(&run_time_tests.step);
    test_step.dependOn(&run_containers_tests.step);
    test_step.dependOn(&run_crypto_tests.step);

    test_core_step.dependOn(&run_memory_tests.step);
    test_core_step.dependOn(&run_time_tests.step);
    test_core_step.dependOn(&run_containers_tests.step);
    test_core_step.dependOn(&run_crypto_tests.step);

    // ---- Protocol test steps ----
    const test_protocol_step = b.step("test-protocol", "Run sdk/protocol tests");

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

    const run_itch_tests = b.addRunArtifact(proto_itch_tests);
    const run_sbe_tests = b.addRunArtifact(proto_sbe_tests);
    const run_fast_tests = b.addRunArtifact(proto_fast_tests);
    const run_ouch_tests = b.addRunArtifact(proto_ouch_tests);
    const run_pitch_tests = b.addRunArtifact(proto_pitch_tests);

    test_protocol_step.dependOn(&run_itch_tests.step);
    test_protocol_step.dependOn(&run_sbe_tests.step);
    test_protocol_step.dependOn(&run_fast_tests.step);
    test_protocol_step.dependOn(&run_ouch_tests.step);
    test_protocol_step.dependOn(&run_pitch_tests.step);

    // Add protocol tests to global test step
    test_step.dependOn(&run_itch_tests.step);
    test_step.dependOn(&run_sbe_tests.step);
    test_step.dependOn(&run_fast_tests.step);
    test_step.dependOn(&run_ouch_tests.step);
    test_step.dependOn(&run_pitch_tests.step);
}
