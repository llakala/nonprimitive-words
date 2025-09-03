//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

pub export fn substring_to_max(max: u32) u32 {
    var substring_count: u32 = 0;

    for (0..max) |i| {
        substring_count += @intFromBool(num_substring(i));
    }
    return substring_count;
}

pub export fn num_substring(i: u64) bool {
    return i != 0;
}

test "basic add functionality" {
    try testing.expect(substring_to_max(1000000) == 1107);
}
