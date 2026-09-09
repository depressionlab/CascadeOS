// SPDX-License-Identifier: BSD-3-Clause
// SPDX-FileCopyrightText: CascadeOS Contributors

const std = @import("std");

const core = @import("core");

/// Represents a size in bytes.
pub const Size = enum(u64) {
    zero = 0,
    one = 1,

    _,

    pub const Unit = enum(u64) {
        byte = 1,
        kib = 1024,
        mib = 1024 * 1024,
        gib = 1024 * 1024 * 1024,
        tib = 1024 * 1024 * 1024 * 1024,
    };

    pub inline fn of(comptime T: type) Size {
        return @enumFromInt(@sizeOf(T));
    }

    pub fn from(amount: u64, unit: Unit) Size {
        return @enumFromInt(amount * @intFromEnum(unit));
    }

    pub inline fn toAlignment(size: core.Size) std.mem.Alignment {
        return .fromByteUnits(@intFromEnum(size));
    }

    pub inline fn aligned(size: Size, alignment: std.mem.Alignment) bool {
        return alignment.check(@intFromEnum(size));
    }

    pub inline fn alignForward(size: Size, alignment: std.mem.Alignment) Size {
        return @enumFromInt(alignment.forward(@intFromEnum(size)));
    }

    pub inline fn alignForwardInPlace(size: *Size, alignment: std.mem.Alignment) void {
        size.* = @enumFromInt(alignment.forward(@intFromEnum(size.*)));
    }

    pub inline fn alignBackward(size: Size, alignment: std.mem.Alignment) Size {
        return @enumFromInt(alignment.backward(@intFromEnum(size)));
    }

    pub inline fn alignBackwardInPlace(size: *Size, alignment: std.mem.Alignment) void {
        size.* = @enumFromInt(alignment.backward(@intFromEnum(size.*)));
    }

    /// Returns the amount of `size` sizes needed to cover `target`.
    ///
    /// Caller must ensure `size` is not zero.
    pub fn amountToCover(size: Size, target: Size) u64 {
        return target.add(size.subtract(.one)).divide(size);
    }

    test amountToCover {
        {
            const size: Size = .from(10, .byte);
            const target: Size = .from(25, .byte);
            const expected: u64 = 3;

            try std.testing.expectEqual(expected, size.amountToCover(target));
        }

        {
            const size: Size = .one;
            const target: Size = .from(30, .byte);
            const expected: u64 = 30;

            try std.testing.expectEqual(expected, size.amountToCover(target));
        }

        {
            const size: Size = .from(100, .byte);
            const target: Size = .from(100, .byte);
            const expected: u64 = 1;

            try std.testing.expectEqual(expected, size.amountToCover(target));
        }

        {
            const size: Size = .from(512, .byte);
            const target: Size = .from(64, .mib);
            const expected: u64 = 131072;

            try std.testing.expectEqual(expected, size.amountToCover(target));
        }
    }

    pub inline fn equal(size: Size, other: Size) bool {
        return @intFromEnum(size) == @intFromEnum(other);
    }

    pub inline fn notEqual(size: Size, other: Size) bool {
        return @intFromEnum(size) != @intFromEnum(other);
    }

    pub inline fn lessThan(size: Size, other: Size) bool {
        return @intFromEnum(size) < @intFromEnum(other);
    }

    pub inline fn lessThanOrEqual(size: Size, other: Size) bool {
        return @intFromEnum(size) <= @intFromEnum(other);
    }

    pub inline fn greaterThan(size: Size, other: Size) bool {
        return @intFromEnum(size) > @intFromEnum(other);
    }

    pub inline fn greaterThanOrEqual(size: Size, other: Size) bool {
        return @intFromEnum(size) >= @intFromEnum(other);
    }

    pub fn compare(size: Size, other: Size) std.math.Order {
        if (size.lessThan(other)) return .lt;
        if (size.greaterThan(other)) return .gt;
        return .eq;
    }

    pub fn add(size: Size, other: Size) Size {
        return @enumFromInt(@intFromEnum(size) + @intFromEnum(other));
    }

    pub fn addInPlace(size: *Size, other: Size) void {
        size.* = size.add(other);
    }

    pub fn subtract(size: Size, other: Size) Size {
        return @enumFromInt(@intFromEnum(size) - @intFromEnum(other));
    }

    pub fn subtractInPlace(size: *Size, other: Size) void {
        size.* = size.subtract(other);
    }

    pub fn multiplyScalar(size: Size, value: u64) Size {
        return @enumFromInt(@intFromEnum(size) * value);
    }

    pub fn multiplyScalarInPlace(size: *Size, value: u64) void {
        size.* = size.multiplyScalar(value);
    }

    pub fn divide(size: Size, other: Size) usize {
        return @intFromEnum(size) / @intFromEnum(other);
    }

    pub fn divideScalar(size: Size, value: u64) Size {
        return @enumFromInt(@intFromEnum(size) / value);
    }

    pub fn divideScalarInPlace(size: *Size, value: u64) void {
        size.* = size.divideScalar(value);
    }

    // Must be kept in descending size order due to the logic in `print`
    const unit_table = .{
        .{ .value = @intFromEnum(Unit.tib), .name = "TiB" },
        .{ .value = @intFromEnum(Unit.gib), .name = "GiB" },
        .{ .value = @intFromEnum(Unit.mib), .name = "MiB" },
        .{ .value = @intFromEnum(Unit.kib), .name = "KiB" },
        .{ .value = @intFromEnum(Unit.byte), .name = "B" },
    };

    pub fn print(size: Size, writer: *std.Io.Writer, indent: usize) !void {
        _ = indent;

        var value = @intFromEnum(size);

        if (value == 0) {
            try writer.writeAll("0 bytes");
            return;
        }

        var emitted_anything = false;

        inline for (unit_table) |unit| blk: {
            if (value < unit.value) break :blk; // continue loop

            const part = value / unit.value;

            if (emitted_anything) try writer.writeAll(", ");

            try writer.printInt(part, 10, .lower, .{});
            try writer.writeAll(comptime " " ++ unit.name);

            value -= part * unit.value;
            emitted_anything = true;
        }
    }

    pub inline fn format(size: Size, writer: *std.Io.Writer) !void {
        return print(size, writer, 0);
    }

    comptime {
        core.testing.expectSize(Size, .of(u64));
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
