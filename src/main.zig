const std = @import("std");

const Day = enum {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,

    pub fn toString(self: Day) []const u8 {
        switch (self) {
            Sunday => "Sunday",
            Monday => "Monday",
            Tuesday => "Tuesday",
            Wednesday => "Wednesday",
            Thursday => "Thursday",
            Friday => "Friday",
            Saturday => "Saturday",
        }
    }
};

const Month = enum(u8) {
    January = 1,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    November,
    December,
};

const Date = struct {
    year: u16,
    month: Month,
    day: u8,
};

fn isLeap(y: u16) bool {
    return y % 400 == 0 or y % 100 != 0 and y % 4 == 0;
}

test "leap years" {
    std.testing.expect(isLeap(2000));
    std.testing.expect(isLeap(1996));
    std.testing.expect(!isLeap(1900));
}

fn anchorDay(y: u16) u8 {
    unreachable;
}

pub fn main() !void {}
