//! Coverage data collection for zcov.
//!
//! Reads the `SeenPcsHeader` memory-mapped files produced by `-ffuzz`
//! instrumented test binaries and maps covered PCs back to source locations
//! using std.debug.Info (DWARF / ELF).

const std = @import("std");
const Allocator = std.mem.Allocator;
const Coverage = std.debug.Coverage;
const SourceLocation = std.debug.Coverage.SourceLocation;
const Info = std.debug.Info;
const SeenPcsHeader = std.Build.abi.fuzz.SeenPcsHeader;
const Path = std.Build.Cache.Path;

/// Per-file coverage data aggregated from one or more test binaries.
pub const CoverageData = struct {
    source_file: []const u8,
    /// One element per source line (1-indexed; index 0 unused).
    lines_hit: []bool,
    total_lines: u32,
    covered_lines: u32,

    pub fn deinit(self: CoverageData, allocator: Allocator) void {
        allocator.free(self.source_file);
        allocator.free(self.lines_hit);
    }
};

/// Read all `v/<hex>` files from `cache_dir_path` that were produced by a
/// `-ffuzz` instrumented test run, then resolve covered PCs to source
/// locations using the ELF binary at `test_binary_path`.
///
/// Caller owns returned slice (call `deinit` on each element, then free).
pub fn collectCoverage(
    allocator: Allocator,
    test_binary_path: []const u8,
    cache_dir_path: []const u8,
) ![]CoverageData {
    // --- 1. Load debug information from the test binary --------------------
    var cov: Coverage = Coverage.init;
    defer cov.deinit(allocator);

    const bin_path = Path.initCwd(test_binary_path);
    var info = Info.load(allocator, bin_path, &cov) catch |err| {
        std.log.warn("zcov: failed to load debug info from '{s}': {s}", .{ test_binary_path, @errorName(err) });
        return &.{};
    };
    defer info.deinit(allocator);

    // --- 2. Collect all PC addresses from coverage files in the cache dir --
    const covered_pcs = try readAllCoveredPcs(allocator, cache_dir_path);
    defer allocator.free(covered_pcs);

    if (covered_pcs.len == 0) return &.{};

    // --- 3. Sort PCs ascending (required by resolveAddresses) ---------------
    std.mem.sort(u64, covered_pcs, {}, std.sort.asc(u64));

    // --- 4. Resolve PCs → source locations ----------------------------------
    const src_locs = try allocator.alloc(SourceLocation, covered_pcs.len);
    defer allocator.free(src_locs);

    info.resolveAddresses(allocator, covered_pcs, src_locs) catch |err| {
        std.log.warn("zcov: failed to resolve addresses: {s}", .{@errorName(err)});
        return &.{};
    };

    // --- 5. Aggregate by source file ----------------------------------------
    return aggregateByFile(allocator, src_locs, &cov);
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// Read every `v/<hex>` file in `cache_dir_path/v/` and collect all PC
/// addresses that have their seen-bit set.
fn readAllCoveredPcs(allocator: Allocator, cache_dir_path: []const u8) ![]u64 {
    var pc_set = std.AutoArrayHashMap(u64, void).init(allocator);
    defer pc_set.deinit();

    const cache_dir = std.fs.openDirAbsolute(cache_dir_path, .{ .iterate = true }) catch |err| {
        std.log.warn("zcov: cannot open cache dir '{s}': {s}", .{ cache_dir_path, @errorName(err) });
        return allocator.dupe(u64, &.{});
    };
    defer @constCast(&cache_dir).close();

    const v_dir = cache_dir.openDir("v", .{ .iterate = true }) catch |err| {
        std.log.warn("zcov: no coverage dir in '{s}': {s}", .{ cache_dir_path, @errorName(err) });
        return allocator.dupe(u64, &.{});
    };
    defer @constCast(&v_dir).close();

    var iter = v_dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        try readCoveredPcsFromFile(allocator, v_dir, entry.name, &pc_set);
    }

    const result = try allocator.alloc(u64, pc_set.count());
    for (pc_set.keys(), 0..) |pc, i| result[i] = pc;
    return result;
}

/// Parse a single `SeenPcsHeader`-formatted file and add covered PC
/// addresses to `pc_set`.
fn readCoveredPcsFromFile(
    allocator: Allocator,
    dir: std.fs.Dir,
    name: []const u8,
    pc_set: *std.AutoArrayHashMap(u64, void),
) !void {
    const file = dir.openFile(name, .{}) catch return;
    defer file.close();

    const stat = try file.stat();
    if (stat.size < @sizeOf(SeenPcsHeader)) return;

    const data = try file.readToEndAlloc(allocator, 64 * 1024 * 1024);
    defer allocator.free(data);

    if (data.len < @sizeOf(SeenPcsHeader)) return;
    const header: *const SeenPcsHeader = @ptrCast(@alignCast(data.ptr));

    const pcs_len = header.pcs_len;
    const required = @sizeOf(SeenPcsHeader) +
        SeenPcsHeader.seenElemsLen(pcs_len) * @sizeOf(usize) +
        pcs_len * @sizeOf(usize);
    if (data.len < required) return;

    const seen_bits = header.seenBits();
    const pc_addrs = header.pcAddrs();

    for (pc_addrs, 0..) |pc, i| {
        const word = seen_bits[i / @bitSizeOf(usize)];
        const bit: usize = @as(usize, 1) << @intCast(i % @bitSizeOf(usize));
        if (word & bit != 0) {
            try pc_set.put(@intCast(pc), {});
        }
    }
}

/// Build per-file `CoverageData` entries from the resolved source locations.
fn aggregateByFile(
    allocator: Allocator,
    src_locs: []const SourceLocation,
    cov: *Coverage,
) ![]CoverageData {
    // Map source file path → set of covered line numbers.
    const StringMap = std.StringHashMap(std.AutoArrayHashMap(u32, void));
    var file_lines = StringMap.init(allocator);
    defer {
        var it = file_lines.iterator();
        while (it.next()) |entry| entry.value_ptr.deinit();
        file_lines.deinit();
    }

    for (src_locs) |loc| {
        if (loc.file == .invalid or loc.line == 0) continue;
        const file_entry = cov.fileAt(loc.file);
        // file_entry.directory_index is an index into cov.directories.keys()
        // Each key is a Coverage.String (enum(u32)), resolve via stringAt.
        const dir_string: Coverage.String = cov.directories.keys()[file_entry.directory_index];
        const dir_str = cov.stringAt(dir_string);
        const name_str = cov.stringAt(file_entry.basename);

        // Build full path: dir/basename
        const full_path = try std.fs.path.join(allocator, &.{ dir_str, name_str });

        const gop = try file_lines.getOrPut(full_path);
        if (!gop.found_existing) {
            gop.value_ptr.* = std.AutoArrayHashMap(u32, void).init(allocator);
        } else {
            allocator.free(full_path);
        }
        try gop.value_ptr.put(loc.line, {});
    }

    // Convert to CoverageData array.
    var result: std.ArrayList(CoverageData) = .empty;
    errdefer {
        for (result.items) |item| item.deinit(allocator);
        result.deinit(allocator);
    }

    var it = file_lines.iterator();
    while (it.next()) |entry| {
        const path = entry.key_ptr.*;
        const lines = entry.value_ptr.*;

        // Find max line number to size the lines_hit array.
        var max_line: u32 = 0;
        for (lines.keys()) |ln| if (ln > max_line) { max_line = ln; };

        const lines_hit = try allocator.alloc(bool, max_line + 1);
        @memset(lines_hit, false);
        for (lines.keys()) |ln| lines_hit[ln] = true;

        try result.append(allocator, .{
            .source_file = try allocator.dupe(u8, path),
            .lines_hit = lines_hit,
            .total_lines = max_line,
            .covered_lines = @intCast(lines.count()),
        });
    }

    return result.toOwnedSlice(allocator);
}
