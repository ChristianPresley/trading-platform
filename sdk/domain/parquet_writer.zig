const std = @import("std");

pub const ParquetType = enum {
    int32,
    int64,
    float,
    double,
    byte_array,
};

pub const Repetition = enum {
    required,
    optional,
    repeated,
};

pub const ColumnDef = struct {
    name: []const u8,
    type: ParquetType,
    repetition: Repetition,
};

pub const Schema = struct {
    columns: []const ColumnDef,
};

pub const Column = struct {
    def: ColumnDef,
    data: []const u8,
};

/// Minimal Parquet writer: writes PAR1 magic, column data, and footer.
/// Format: [PAR1 magic 4B][row groups][footer][footer_len 4B LE][PAR1 magic 4B]
pub const ParquetWriter = struct {
    allocator: std.mem.Allocator,
    file: std.fs.File,
    schema: Schema,
    /// Track total rows written (for footer metadata)
    total_rows: u64,
    /// Footer metadata buffer
    row_group_meta: std.ArrayList(u8),

    const MAGIC = "PAR1";

    pub fn init(allocator: std.mem.Allocator, path: []const u8, schema: Schema) !ParquetWriter {
        const file = try std.fs.createFileAbsolute(path, .{ .read = true, .truncate = true });
        errdefer file.close();

        // Write PAR1 magic header
        _ = try file.write(MAGIC);

        return ParquetWriter{
            .allocator = allocator,
            .file = file,
            .schema = schema,
            .total_rows = 0,
            .row_group_meta = .{},
        };
    }

    /// Write a row group (collection of column chunks).
    pub fn writeRowGroup(self: *ParquetWriter, columns: []const Column) !void {
        if (columns.len == 0) return;

        // Determine row count from first column
        // For PLAIN encoding: write page header (simplified) + data
        for (columns) |col| {
            // Write a simplified page header:
            // [data_page_header: 4 bytes magic 'PAGE'][num_values: 4B LE][encoding: 1B][data]
            var hdr: [9]u8 = undefined;
            @memcpy(hdr[0..4], "PAGE");
            const num_values: u32 = @as(u32, @intCast(col.data.len / columnWidth(col.def.type)));
            std.mem.writeInt(u32, hdr[4..8], num_values, .little);
            hdr[8] = 0; // PLAIN encoding
            _ = try self.file.write(&hdr);
            _ = try self.file.write(col.data);
        }

        // Track for footer (simplified: just record columns.len)
        var rg_entry: [8]u8 = undefined;
        std.mem.writeInt(u32, rg_entry[0..4], @as(u32, @intCast(columns.len)), .little);
        std.mem.writeInt(u32, rg_entry[4..8], @as(u32, @intCast(self.total_rows & 0xFFFFFFFF)), .little);
        try self.row_group_meta.appendSlice(self.allocator, &rg_entry);
    }

    /// Close the file: write footer with schema + row group metadata, then PAR1 magic.
    pub fn close(self: *ParquetWriter) !void {
        defer {
            self.row_group_meta.deinit(self.allocator);
            self.file.close();
        }

        // Write footer: schema info (simplified) + row group metadata
        var footer: std.ArrayList(u8) = .{};
        defer footer.deinit(self.allocator);

        // Write number of schema columns (4 bytes LE)
        var col_count: [4]u8 = undefined;
        std.mem.writeInt(u32, &col_count, @as(u32, @intCast(self.schema.columns.len)), .little);
        try footer.appendSlice(self.allocator, &col_count);

        // Write each column definition (name_len: 2B + name + type: 1B + repetition: 1B)
        for (self.schema.columns) |col| {
            var name_len: [2]u8 = undefined;
            std.mem.writeInt(u16, &name_len, @as(u16, @intCast(col.name.len)), .little);
            try footer.appendSlice(self.allocator, &name_len);
            try footer.appendSlice(self.allocator, col.name);
            try footer.append(self.allocator, @intFromEnum(col.type));
            try footer.append(self.allocator, @intFromEnum(col.repetition));
        }

        // Write row group metadata
        try footer.appendSlice(self.allocator, self.row_group_meta.items);

        const footer_bytes = footer.items;
        const footer_len = @as(u32, @intCast(footer_bytes.len));

        _ = try self.file.write(footer_bytes);

        // Write footer length as 4 bytes LE
        var footer_len_bytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &footer_len_bytes, footer_len, .little);
        _ = try self.file.write(&footer_len_bytes);

        // Write PAR1 magic at end
        _ = try self.file.write(MAGIC);
    }

    fn columnWidth(pt: ParquetType) usize {
        return switch (pt) {
            .int32 => 4,
            .float => 4,
            .int64 => 8,
            .double => 8,
            .byte_array => 1, // variable; treat as 1 for row count estimation
        };
    }
};
