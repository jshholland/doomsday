const std = @import("std");

const Day = enum {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,

    fn toString(self: Day) []const u8 {
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
};

const Date = struct {
    year: u16,
    month: Month,
    day: u8,

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
        return @intToEnum(Day, @intCast(u3, (self.day + 35 - d + dd) % 7));
    }
};

test "day of week" {
    const d1 = Date{ .year = 2020, .month = .October, .day = 12 };
    std.testing.expect(d1.dayOfWeek() == .Monday);
    const d2 = Date{ .year = 1815, .month = .February, .day = 14 };
    std.testing.expect(d2.dayOfWeek() == .Tuesday);
}

fn isLeap(y: u16) bool {
    return y % 400 == 0 or y % 100 != 0 and y % 4 == 0;
}

test "leap years" {
    std.testing.expect(isLeap(2000));
    std.testing.expect(isLeap(1996));
    std.testing.expect(!isLeap(1900));
}

fn centuryAnchor(y: u16) u8 {
    const c = @intCast(u8, y / 100 % 4);
    return (5 * c + 2) % 7;
}

test "century anchors" {
    std.testing.expect(centuryAnchor(1776) == 0);
    std.testing.expect(centuryAnchor(1837) == 5);
    std.testing.expect(centuryAnchor(1952) == 3);
    std.testing.expect(centuryAnchor(2001) == 2);
}

fn doomsday(y: u16) u8 {
    const anchor = centuryAnchor(y);
    const year = @intCast(u8, y % 100);
    return (year + year / 4 + anchor) % 7;
}

test "doomsday calculation" {
    std.testing.expect(doomsday(2020) == 6);
    std.testing.expect(doomsday(1966) == 1);
    std.testing.expect(doomsday(1939) == 2);
}

pub fn main() !void {}
