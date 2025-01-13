// simple
export fn sum(a : i32, b : i32) i32 {
  return a + b;
}

const std = @import("std");
export fn printSt(s : [*]const u8) void {
  std.debug.print("string {*}\n", .{s});
}