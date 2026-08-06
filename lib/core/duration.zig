// SPDX-License-Identifier: BSD-3-Clause
// SPDX-FileCopyrightText: CascadeOS Contributors

const std = @import("std");

const core = @import("core");

/// Represents a duration.
pub const Duration = enum(u64) {
    zero = 0,
    one = 1,

    _,

    pub const Unit = enum(u64) {
        nanosecond = 1,
        microsecond = 1000,
        millisecond = 1000 * 1000,
        second = 1000 * 1000 * 1000,
        minute = 60 * 1000 * 1000 * 1000,
        hour = 60 * 60 * 1000 * 1000 * 1000,
        day = 24 * 60 * 60 * 1000 * 1000 * 1000,
    };

    pub fn from(amount: u64, unit: Unit) Duration {
        return @enumFromInt(amount * @intFromEnum(unit));
    }

    pub inline fn equal(duration: Duration, other: Duration) bool {
        return @intFromEnum(duration) == @intFromEnum(other);
    }

    pub inline fn lessThan(duration: Duration, other: Duration) bool {
        return @intFromEnum(duration) < @intFromEnum(other);
    }

    pub inline fn lessThanOrEqual(duration: Duration, other: Duration) bool {
        return @intFromEnum(duration) <= @intFromEnum(other);
    }

    pub inline fn greaterThan(duration: Duration, other: Duration) bool {
        return @intFromEnum(duration) > @intFromEnum(other);
    }

    pub inline fn greaterThanOrEqual(duration: Duration, other: Duration) bool {
        return @intFromEnum(duration) >= @intFromEnum(other);
    }

    pub fn compare(duration: Duration, other: Duration) std.math.Order {
        if (duration.lessThan(other)) return .lt;
        if (duration.greaterThan(other)) return .gt;
        return .eq;
    }

    pub fn add(duration: Duration, other: Duration) Duration {
        return @enumFromInt(@intFromEnum(duration) + @intFromEnum(other));
    }

    pub fn addInPlace(duration: *Duration, other: Duration) void {
        duration.* = @enumFromInt(@intFromEnum(duration.*) + @intFromEnum(other));
    }

    pub fn subtract(duration: Duration, other: Duration) Duration {
        return @enumFromInt(@intFromEnum(duration) - @intFromEnum(other));
    }

    pub fn subtractInPlace(duration: *Duration, other: Duration) void {
        duration.* = @enumFromInt(@intFromEnum(duration.*) - @intFromEnum(other));
    }

    pub fn multiplyScalar(duration: Duration, value: u64) Duration {
        return @enumFromInt(@intFromEnum(duration) * value);
    }

    pub fn multiplyScalarInPlace(duration: *Duration, value: u64) void {
        duration.* = @enumFromInt(@intFromEnum(duration.*) * value);
    }

    pub fn divide(duration: Duration, other: Duration) Duration {
        return @enumFromInt(@intFromEnum(duration) / @intFromEnum(other));
    }

    pub fn divideInPlace(duration: *Duration, other: Duration) void {
        duration.* = @enumFromInt(@intFromEnum(duration.*) / @intFromEnum(other));
    }

    pub fn divideScalar(duration: Duration, value: u64) Duration {
        return @enumFromInt(@intFromEnum(duration) / value);
    }

    pub fn divideScalarInPlace(duration: *Duration, value: u64) void {
        duration.* = @enumFromInt(@intFromEnum(duration.*) / value);
    }

    pub fn print(duration: Duration, writer: *std.Io.Writer, indent: usize) !void {
        _ = indent;

        var any_output = false;
        var value = @intFromEnum(duration);

        if (value == 0) {
            try writer.writeAll("0.000000000");
            return;
        }

        const days = value / @intFromEnum(Unit.day);
        value -= days * @intFromEnum(Unit.day);

        if (days != 0) {
            try writer.printInt(days, 10, .lower, .{});
            try writer.writeByte('.');
            any_output = true;
        }

        const hours = value / @intFromEnum(Unit.hour);
        value -= hours * @intFromEnum(Unit.hour);

        if (hours != 0 or any_output) {
            try writer.printInt(hours, 10, .lower, .{ .fill = '0', .width = 2 });
            try writer.writeByte(':');
            any_output = true;
        }

        const minutes = value / @intFromEnum(Unit.minute);
        value -= minutes * @intFromEnum(Unit.minute);

        if (minutes != 0 or any_output) {
            try writer.printInt(minutes, 10, .lower, .{ .fill = '0', .width = 2 });
            try writer.writeByte(':');
            any_output = true;
        }

        const seconds = value / @intFromEnum(Unit.second);
        value -= seconds * @intFromEnum(Unit.second);

        try writer.printInt(seconds, 10, .lower, .{ .fill = '0', .width = 2 });
        try writer.writeByte('.');

        try writer.printInt(value, 10, .lower, .{ .fill = '0', .width = 9 });
    }

    pub inline fn format(duration: Duration, writer: *std.Io.Writer) !void {
        return print(duration, writer, 0);
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
