const std = @import("std");
const expect = std.testing.expect;
var counter: i16 = 0;
fn controlledOperation(op: bool, val: i16, orig: i16) i16 {
    var temp_val: i16 = val;
    temp_val = @mod(val, 100);
    if (op) { // Subtraction
        temp_val = orig - temp_val;
        if (temp_val < 0) {
            temp_val = temp_val + 100;
        } else {}
    } else if (op == false) { // Addition
        temp_val = orig + temp_val;
        if (temp_val > 99) {
            temp_val = temp_val - 100;
        } else {}
    }

    return temp_val;
}

fn operationConsideringPassProt(direction: bool, value: usize, original: i16) [2]i16 {
    var temp_val: i16 = original;
    var local_hits: i16 = 0;

    // Loop 'value' times
    for (0..value) |_| { // We don't need the index 'i'
        if (direction) {
            // Subtraction / Left
            temp_val -= 1;
            if (temp_val < 0) {
                temp_val = 99; // Wrap to top (assuming 0-99 range)
            }
        } else {
            // Addition / Right
            temp_val += 1;
            if (temp_val > 99) { // Assuming 0-99 range
                temp_val = 0;
            }
        }

        if (temp_val == 0) {
            local_hits += 1;
        }
    }

    return .{ local_hits, temp_val };
}

fn increm_ret() void {
    counter += 1;
}
pub fn main() !void {
    var inputData = try std.fs.cwd().openFile("inputdata.txt", .{});
    const swith: bool = false;
    var safeValue: i16 = 50;

    const inputSize: u64 = (try inputData.stat()).size;
    var buf: [1024]u8 = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    const data_alloc: []u8 = try allocator.alloc(u8, inputSize);

    var selectList: std.ArrayList([]u8) = try std.ArrayList([]u8).initCapacity(allocator, inputSize);

    var in_stream = inputData.reader(&buf);
    const unknown_val: usize = try in_stream.readPositional(data_alloc);
    var increm: u64 = 0;
    var delimiter_increm: u64 = 0;
    std.debug.print("Unknown val is {x}", .{unknown_val});
    // Look for first /n in file and index it relative to the last one. On the first line (i.e where a first /n does not exist), simply index 0
    for (data_alloc, 0..) |byte, index| {
        if (byte == '\n') {
            delimiter_increm = index;

            const line_slice = data_alloc[increm..delimiter_increm];

            try selectList.append(allocator, line_slice);
            increm = delimiter_increm + 1;
        }
    }
    if (swith) {
        for (selectList.items, 0..) |item, i| {
            std.debug.print(" ...   Iterating on row {d}\n", .{i});
            if (item[0] == 'L') {
                const used_slice: []u8 = item[1..item.len];
                const sliced_int: i16 = try std.fmt.parseInt(i16, used_slice, 10);
                const result: i16 = controlledOperation(false, sliced_int, safeValue);
                safeValue = result;

                if (result == 0) {
                    std.debug.print(" !!   Hit at line {d}\n", .{i});
                    counter += 1;
                }
            } else if (item[0] == 'R') {
                const used_slice: []u8 = item[1..item.len];
                const sliced_int: i16 = try std.fmt.parseInt(i16, used_slice, 10);
                const result: i16 = controlledOperation(true, sliced_int, safeValue);
                safeValue = result;
                if (result == 0) {
                    std.debug.print(" !!   Hit at line {d}\n", .{i});
                    counter += 1;
                }
            }
        }
    } else {
        std.debug.print("Switch Disabled! Continuing in {s} mode... \n", .{"Iterator"});
        for (selectList.items, 0..) |item, i| {
            std.debug.print(" ...   Iterating on row {d}\n", .{i});
            if (item[0] == 'L') {
                const used_slice: []u8 = item[1..item.len];
                const sliced_int: i16 = try std.fmt.parseInt(i16, used_slice, 10);
                const casted_int: usize = @intCast(sliced_int);
                const result: [2]i16 = operationConsideringPassProt(false, casted_int, safeValue);
                safeValue = result[1];
                counter += result[0];
            } else if (item[0] == 'R') {
                const used_slice: []u8 = item[1..item.len];
                const sliced_int: i16 = try std.fmt.parseInt(i16, used_slice, 10);
                const casted_int: usize = @intCast(sliced_int);
                const result: [2]i16 = operationConsideringPassProt(true, casted_int, safeValue);
                safeValue = result[1];
                counter += result[0];
            }
        }
    }
    std.debug.print("Size of file is {d} KB", .{inputSize / 1024});
    std.debug.print("Safe Value is {d}\n", .{counter});
    defer allocator.free(data_alloc);
    defer inputData.close();
    //std.debug.print("Data alloc is {c}", .{data_alloc});
    // while () {
    //    if (line[0] == 'L') {} else if (line[0] == 'R') {}
    // }
}
test "Controlled Addition" {
    var currentValue: i16 = 50;
    var numbers = blk: {
        var tmp: [32767]i16 = undefined; // max value
        for (&tmp, 0..) |*item, i| {
            item.* = @intCast(i);
        }
        break :blk tmp;
    };
    const sampleData: []i16 = &numbers;
    var flag: bool = true;
    for (sampleData) |num| {
        currentValue = controlledOperation(true, num, currentValue);
        if ((currentValue >= 0 and currentValue < 100) == false) {
            flag = false;
            std.debug.print("Incriminating value is {d}", .{currentValue});
        }
        try expect(flag);
    }
}
test "Controlled Subtraction" {
    var currentValue: i16 = 50;
    var numbers = blk: {
        var tmp: [32767]i16 = undefined; // max value
        for (&tmp, 0..) |*item, i| {
            item.* = @intCast(i);
        }
        break :blk tmp;
    };
    const sampleData: []i16 = &numbers;
    var flag: bool = true;
    for (sampleData) |num| {
        currentValue = controlledOperation(false, num, currentValue);
        if ((currentValue >= 0 and currentValue < 100) == false) {
            flag = false;
            std.debug.print("Incriminating value is {d}", .{currentValue});
        }
        try expect(flag);
    }
}
