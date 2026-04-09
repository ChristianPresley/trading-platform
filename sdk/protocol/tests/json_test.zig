// JSON parser tests

const std = @import("std");
const json = @import("json");

test "parse empty object" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("{}");
    try std.testing.expect(val == .object);
    try std.testing.expectEqual(@as(usize, 0), val.object.len);
}

test "parse empty array" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("[]");
    try std.testing.expect(val == .array);
    try std.testing.expectEqual(@as(usize, 0), val.array.len);
}

test "parse boolean true" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("true");
    try std.testing.expect(val == .boolean);
    try std.testing.expect(val.boolean == true);
}

test "parse boolean false" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("false");
    try std.testing.expect(val == .boolean);
    try std.testing.expect(val.boolean == false);
}

test "parse null" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("null");
    try std.testing.expect(val == .null_value);
}

test "parse integer" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("42");
    try std.testing.expect(val == .integer);
    try std.testing.expectEqual(@as(i64, 42), val.integer);
}

test "parse negative integer" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("-17");
    try std.testing.expect(val == .integer);
    try std.testing.expectEqual(@as(i64, -17), val.integer);
}

test "parse zero" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("0");
    try std.testing.expect(val == .integer);
    try std.testing.expectEqual(@as(i64, 0), val.integer);
}

test "parse float" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("3.14");
    try std.testing.expect(val == .number);
    try std.testing.expectApproxEqAbs(3.14, val.number, 0.001);
}

test "parse negative float" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("-2.718");
    try std.testing.expect(val == .number);
    try std.testing.expectApproxEqAbs(-2.718, val.number, 0.001);
}

test "parse scientific notation" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("1.5e10");
    try std.testing.expect(val == .number);
    try std.testing.expectApproxEqAbs(1.5e10, val.number, 1.0);
}

test "parse negative scientific notation" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("2.5E-3");
    try std.testing.expect(val == .number);
    try std.testing.expectApproxEqAbs(0.0025, val.number, 0.000001);
}

test "parse string" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("\"hello world\"");
    try std.testing.expect(val == .string);
    try std.testing.expectEqualStrings("hello world", val.string);
    std.testing.allocator.free(val.string);
}

test "parse string with escape sequences" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("\"line1\\nline2\\ttab\"");
    try std.testing.expect(val == .string);
    try std.testing.expectEqualStrings("line1\nline2\ttab", val.string);
    std.testing.allocator.free(val.string);
}

test "parse string with unicode escape" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("\"\\u0041\""); // 'A'
    try std.testing.expect(val == .string);
    try std.testing.expectEqualStrings("A", val.string);
    std.testing.allocator.free(val.string);
}

test "parse unicode surrogate pair" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    // U+1F600 GRINNING FACE = \uD83D\uDE00
    const val = try parser.parse("\"\\uD83D\\uDE00\"");
    try std.testing.expect(val == .string);
    // UTF-8 encoding of U+1F600 is F0 9F 98 80
    try std.testing.expectEqual(@as(usize, 4), val.string.len);
    try std.testing.expectEqual(@as(u8, 0xF0), val.string[0]);
    std.testing.allocator.free(val.string);
}

test "parse simple object" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("{\"key\":\"value\"}");
    try std.testing.expect(val == .object);
    const v = val.object.get("key");
    try std.testing.expect(v != null);
    try std.testing.expectEqualStrings("value", v.?.string);
    // cleanup
    var obj = val.object;
    obj.deinit(std.testing.allocator);
}

test "parse object with multiple fields" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("{\"a\":1,\"b\":true,\"c\":null}");
    try std.testing.expect(val == .object);
    try std.testing.expectEqual(@as(usize, 3), val.object.len);
    const a = val.object.get("a");
    try std.testing.expect(a != null);
    try std.testing.expectEqual(@as(i64, 1), a.?.integer);
    const b = val.object.get("b");
    try std.testing.expect(b != null);
    try std.testing.expect(b.?.boolean == true);
    var obj = val.object;
    obj.deinit(std.testing.allocator);
}

test "parse nested object" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("{\"outer\":{\"inner\":42}}");
    try std.testing.expect(val == .object);
    const outer = val.object.get("outer");
    try std.testing.expect(outer != null);
    try std.testing.expect(outer.? == .object);
    const inner = outer.?.object.get("inner");
    try std.testing.expect(inner != null);
    try std.testing.expectEqual(@as(i64, 42), inner.?.integer);
    var obj = val.object;
    obj.deinit(std.testing.allocator);
}

test "parse array with elements" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("[1,2,3]");
    try std.testing.expect(val == .array);
    try std.testing.expectEqual(@as(usize, 3), val.array.len);
    try std.testing.expectEqual(@as(i64, 1), val.array[0].integer);
    try std.testing.expectEqual(@as(i64, 2), val.array[1].integer);
    try std.testing.expectEqual(@as(i64, 3), val.array[2].integer);
    std.testing.allocator.free(val.array);
}

test "parse nested array" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("[[1,2],[3,4]]");
    try std.testing.expect(val == .array);
    try std.testing.expectEqual(@as(usize, 2), val.array.len);
    try std.testing.expectEqual(@as(i64, 1), val.array[0].array[0].integer);
    for (val.array) |item| std.testing.allocator.free(item.array);
    std.testing.allocator.free(val.array);
}

test "error: trailing comma in object" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const result = parser.parse("{\"a\":1,}");
    try std.testing.expectError(error.TrailingComma, result);
}

test "error: trailing comma in array" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const result = parser.parse("[1,2,]");
    try std.testing.expectError(error.TrailingComma, result);
}

test "error: unquoted key" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const result = parser.parse("{key:1}");
    try std.testing.expectError(error.ExpectedString, result);
}

test "error: truncated string" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const result = parser.parse("\"unterminated");
    try std.testing.expectError(error.UnterminatedString, result);
}

test "error: unclosed bracket" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const result = parser.parse("[1,2");
    try std.testing.expectError(error.UnexpectedEnd, result);
}

test "error: nesting too deep" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    // Build 101 levels of nesting
    var deep: std.ArrayList(u8) = .empty;
    defer deep.deinit(std.testing.allocator);
    for (0..101) |_| try deep.append(std.testing.allocator, '[');
    try deep.append(std.testing.allocator, '1');
    for (0..101) |_| try deep.append(std.testing.allocator, ']');
    const result = parser.parse(deep.items);
    try std.testing.expectError(error.NestingTooDeep, result);
}

test "stringify round-trip: simple object" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const input = "{\"status\":\"online\",\"count\":42}";
    const val = try parser.parse(input);
    defer {
        var obj = val.object;
        obj.deinit(std.testing.allocator);
    }
    const out = try json.stringifyAlloc(std.testing.allocator, val);
    defer std.testing.allocator.free(out);
    // Re-parse and check
    var parser2 = json.JsonParser.init(std.testing.allocator);
    defer parser2.deinit();
    const val2 = try parser2.parse(out);
    defer {
        var obj = val2.object;
        obj.deinit(std.testing.allocator);
    }
    try std.testing.expectEqual(@as(usize, 2), val2.object.len);
}

test "stringify round-trip: array" {
    var items = [_]json.Value{
        json.Value{ .integer = 1 },
        json.Value{ .integer = 2 },
        json.Value{ .integer = 3 },
    };
    const val = json.Value{ .array = &items };
    const out = try json.stringifyAlloc(std.testing.allocator, val);
    defer std.testing.allocator.free(out);
    try std.testing.expectEqualStrings("[1,2,3]", out);
}

test "stringify: boolean and null" {
    var buf: [64]u8 = undefined;

    const t = json.Value{ .boolean = true };
    const ts = try json.stringify(t, &buf);
    try std.testing.expectEqualStrings("true", ts);

    const f = json.Value{ .boolean = false };
    const fs = try json.stringify(f, &buf);
    try std.testing.expectEqualStrings("false", fs);

    const n = json.Value{ .null_value = {} };
    const ns = try json.stringify(n, &buf);
    try std.testing.expectEqualStrings("null", ns);
}

test "stringify: string with special characters" {
    var buf: [128]u8 = undefined;
    const val = json.Value{ .string = "line1\nline2\ttab\"quote\\backslash" };
    const out = try json.stringify(val, &buf);
    try std.testing.expectEqualStrings("\"line1\\nline2\\ttab\\\"quote\\\\backslash\"", out);
}

test "parse Kraken response format" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const input = "{\"error\":[],\"result\":{\"status\":\"online\"}}";
    const val = try parser.parse(input);
    defer {
        var obj = val.object;
        obj.deinit(std.testing.allocator);
    }

    try std.testing.expect(val == .object);

    // Check error field is empty array
    const err_field = val.object.get("error");
    try std.testing.expect(err_field != null);
    try std.testing.expect(err_field.? == .array);
    try std.testing.expectEqual(@as(usize, 0), err_field.?.array.len);

    // Check result.status == "online"
    const result_field = val.object.get("result");
    try std.testing.expect(result_field != null);
    try std.testing.expect(result_field.? == .object);
    const status = result_field.?.object.get("status");
    try std.testing.expect(status != null);
    try std.testing.expectEqualStrings("online", status.?.string);
}

test "parse with whitespace" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const input =
        \\{
        \\  "key": "value",
        \\  "num": 123
        \\}
    ;
    const val = try parser.parse(input);
    defer {
        var obj = val.object;
        obj.deinit(std.testing.allocator);
    }
    try std.testing.expectEqual(@as(usize, 2), val.object.len);
}

test "object keys method" {
    var parser = json.JsonParser.init(std.testing.allocator);
    defer parser.deinit();
    const val = try parser.parse("{\"a\":1,\"b\":2,\"c\":3}");
    defer {
        var obj = val.object;
        obj.deinit(std.testing.allocator);
    }
    const k = val.object.keys();
    try std.testing.expectEqual(@as(usize, 3), k.len);
    try std.testing.expectEqualStrings("a", k[0]);
    try std.testing.expectEqualStrings("b", k[1]);
    try std.testing.expectEqualStrings("c", k[2]);
}
