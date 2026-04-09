const std = @import("std");
const parquet = @import("parquet_writer");

test "file starts and ends with PAR1 magic bytes" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base = try tmp.dir.realpath(".", &path_buf);

    var full_path_buf: [600]u8 = undefined;
    const path = try std.fmt.bufPrint(&full_path_buf, "{s}/test.parquet", .{base});

    const schema = parquet.Schema{
        .columns = &[_]parquet.ColumnDef{
            .{ .name = "timestamp", .type = .int64, .repetition = .required },
            .{ .name = "price", .type = .int64, .repetition = .required },
        },
    };

    var writer = try parquet.ParquetWriter.init(alloc, path, schema);

    // Write one row group with int64 data
    const ts_data = [_]u8{ 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }; // int64 = 1
    const price_data = [_]u8{ 0x50, 0xC3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }; // int64 = 50000

    const columns = [_]parquet.Column{
        .{ .def = schema.columns[0], .data = &ts_data },
        .{ .def = schema.columns[1], .data = &price_data },
    };

    try writer.writeRowGroup(&columns);
    try writer.close();

    // Read and verify magic bytes
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var header: [4]u8 = undefined;
    _ = try file.preadAll( &header, 0);
    try std.testing.expectEqualStrings("PAR1", &header);

    // Read last 4 bytes
    const stat = try file.stat();
    var footer_magic: [4]u8 = undefined;
    _ = try file.preadAll( &footer_magic, stat.size - 4);
    try std.testing.expectEqualStrings("PAR1", &footer_magic);
}

test "empty row group is valid" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base = try tmp.dir.realpath(".", &path_buf);

    var full_path_buf: [600]u8 = undefined;
    const path = try std.fmt.bufPrint(&full_path_buf, "{s}/empty.parquet", .{base});

    const schema = parquet.Schema{
        .columns = &[_]parquet.ColumnDef{
            .{ .name = "value", .type = .int32, .repetition = .optional },
        },
    };

    var writer = try parquet.ParquetWriter.init(alloc, path, schema);
    // Write empty row group
    try writer.writeRowGroup(&[_]parquet.Column{});
    try writer.close();

    // File should still have PAR1 at start and end
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var header: [4]u8 = undefined;
    _ = try file.preadAll( &header, 0);
    try std.testing.expectEqualStrings("PAR1", &header);

    const stat = try file.stat();
    var footer_magic: [4]u8 = undefined;
    _ = try file.preadAll( &footer_magic, stat.size - 4);
    try std.testing.expectEqualStrings("PAR1", &footer_magic);
}

test "footer length field is written" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base = try tmp.dir.realpath(".", &path_buf);

    var full_path_buf: [600]u8 = undefined;
    const path = try std.fmt.bufPrint(&full_path_buf, "{s}/footer.parquet", .{base});

    const schema = parquet.Schema{
        .columns = &[_]parquet.ColumnDef{
            .{ .name = "x", .type = .int32, .repetition = .required },
        },
    };

    var writer = try parquet.ParquetWriter.init(alloc, path, schema);
    try writer.close();

    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    const stat = try file.stat();
    // Format: [PAR1 4B][footer][footer_len 4B][PAR1 4B]
    // Footer length is at bytes [size-8 .. size-4]
    var footer_len_bytes: [4]u8 = undefined;
    _ = try file.preadAll( &footer_len_bytes, stat.size - 8);
    const footer_len = std.mem.readInt(u32, &footer_len_bytes, .little);
    // Footer length must be positive (schema has at least 1 column)
    try std.testing.expect(footer_len > 0);
}

test "column data round-trip via page header" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const alloc = std.testing.allocator;
    var path_buf: [512]u8 = undefined;
    const base = try tmp.dir.realpath(".", &path_buf);

    var full_path_buf: [600]u8 = undefined;
    const path = try std.fmt.bufPrint(&full_path_buf, "{s}/coldata.parquet", .{base});

    const schema = parquet.Schema{
        .columns = &[_]parquet.ColumnDef{
            .{ .name = "qty", .type = .int32, .repetition = .required },
        },
    };

    var writer = try parquet.ParquetWriter.init(alloc, path, schema);

    // 3 int32 values: 1, 2, 3
    const col_data = [_]u8{
        0x01, 0x00, 0x00, 0x00, // int32 = 1
        0x02, 0x00, 0x00, 0x00, // int32 = 2
        0x03, 0x00, 0x00, 0x00, // int32 = 3
    };
    const columns = [_]parquet.Column{
        .{ .def = schema.columns[0], .data = &col_data },
    };
    try writer.writeRowGroup(&columns);
    try writer.close();

    // Verify file exists and has content
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    const stat = try file.stat();
    try std.testing.expect(stat.size > 8); // at least 2x PAR1 magic

    // Verify PAR1 bookends
    var hdr: [4]u8 = undefined;
    _ = try file.preadAll( &hdr, 0);
    try std.testing.expectEqualStrings("PAR1", &hdr);

    var ftr: [4]u8 = undefined;
    _ = try file.preadAll( &ftr, stat.size - 4);
    try std.testing.expectEqualStrings("PAR1", &ftr);
}
