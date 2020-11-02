const std = @import("std");
const process = std.process;
const Random = std.rand.Random;
const expect = std.testing.expect;
const parseInt = std.fmt.parseInt;

const Day = enum {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
};

const Month = enum {
    January = 1,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December,

    fn numDays(self: Month, leap: bool) u8 {
        return switch (self) {
            .January, .March, .May, .July, .August, .October, .December => 31,
            .April, .June, .September, .November => 30,
            .February => if (leap) @as(u8, 29) else 28,
        };
    }
};

fn randDate(r: *Random) Date {
    const y = r.intRangeLessThan(u16, 1600, 2500);
    const m = @intToEnum(Month, r.intRangeAtMost(@TagType(Month), 1, 12));
    const d = r.intRangeAtMost(u8, 1, m.numDays(isLeap(y)));
    return Date{ .year = y, .month = m, .day = d };
}

const Date = struct {
    year: u16,
    month: Month,
    day: u8,

    pub fn format(self: Date, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: var) !void {
        try writer.print("{} {} {}", .{ self.day, @tagName(self.month), self.year });
    }

    fn dayOfWeek(self: Date) Day {
        const dd = doomsday(self.year);
        const d = switch (self.month) {
            .January => if (isLeap(self.year))
                @as(u8, 4) // appease the type-checker
            else
                3,
            .February => if (isLeap(self.year))
                @as(u8, 29)
            else
                28,
            .March => 0,
            .April => 4,
            .May => 9,
            .June => 6,
            .July => 11,
            .August => 8,
            .September => 5,
            .October => 10,
            .November => 7,
            .December => 12,
        };
        // add 35 (0 mod 7) to avoid underflow, since d is at most 29
        return @intToEnum(Day, @intCast(@TagType(Day), (self.day + 35 - d + dd) % 7));
    }
};

test "day of week" {
    const d1 = Date{ .year = 2020, .month = .October, .day = 12 };
    expect(d1.dayOfWeek() == .Monday);
    const d2 = Date{ .year = 1815, .month = .February, .day = 14 };
    expect(d2.dayOfWeek() == .Tuesday);
}

fn isLeap(y: u16) bool {
    return y % 400 == 0 or y % 100 != 0 and y % 4 == 0;
}

test "leap years" {
    expect(isLeap(2000));
    expect(isLeap(1996));
    expect(!isLeap(1900));
}

fn centuryAnchor(y: u16) u8 {
    const c = y / 100 % 4;
    return @intCast(u8, (5 * c + 2) % 7);
}

test "century anchors" {
    expect(centuryAnchor(1776) == 0);
    expect(centuryAnchor(1837) == 5);
    expect(centuryAnchor(1952) == 3);
    expect(centuryAnchor(2001) == 2);
}

fn doomsday(y: u16) u8 {
    const anchor = centuryAnchor(y);
    const year = y % 100;
    return @intCast(u8, (year + year / 4 + anchor) % 7);
}

test "doomsday calculation" {
    expect(doomsday(2020) == 6);
    expect(doomsday(1966) == 1);
    expect(doomsday(1939) == 2);
}

fn readDay(b: []const u8) ?Day {
    const i = parseInt(@TagType(Day), std.mem.trim(u8, b, " \n"), 10) catch return null;
    if (i >= 7) {
        return null;
    }
    return @intToEnum(Day, i);
}

const maxLineLength = 4096; // as in termios(3)

fn askDay(d: Date) !void {
    const stdout = std.io.getStdOut().outStream();
    const stdin = std.io.getStdIn();
    var b: [maxLineLength]u8 = undefined;
    const day = d.dayOfWeek();
    try stdout.print("{}? ", .{d});
    var t = try std.time.Timer.start();
    while (true) {
        const n = try stdin.read(&b);
        if (readDay(b[0..n])) |read| {
            if (read == day) {
                const seconds = t.read() / 1_000_000_000;
                try stdout.print("Correct! You took {} second{}.\n", .{
                    seconds, plural(seconds),
                });
                return;
            } else {
                try stdout.print("Wrong, try again: ", .{});
            }
        } else {
            try stdout.print("not a day, try again: ", .{});
        }
    }
}

fn plural(n: var) []const u8 {
    if (n == 1) {
        return "";
    } else {
        return "s";
    }
}

pub fn main() !void {
    var mem: [1024]u8 = undefined;
    const alloc = &std.heap.FixedBufferAllocator.init(&mem).allocator;

    var args_it = process.args();
    const exe = try args_it.next(alloc).?;

    const num_questions = if (args_it.next(alloc)) |arg_or_err|
        parseInt(usize, try arg_or_err, 10) catch return usage(exe)
    else
        1;

    if (args_it.next(alloc)) |_| {
        return usage(exe);
    }

    var seed: u64 = undefined;
    try std.crypto.randomBytes(std.mem.asBytes(&seed));
    const rand = &std.rand.DefaultPrng.init(seed).random;

    var asked: usize = 0;
    while (asked < num_questions) : (asked += 1) {
        const date = randDate(rand);
        try askDay(date);
    }
}

fn usage(exe: []const u8) !void {
    std.debug.warn("Usage: {} [number]\n", .{exe});
    return error.Invalid;
}
