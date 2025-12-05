local VIOLATION_METHOD = "EXACTLY_TWICE" -- Options: "AT_LEAST_TWICE", "EXACTLY_TWICE"

local function split(str, delimiter)
    delimiter = delimiter or "%s+"
    local ret = {}
    for substr in string.gmatch(str, "([^" .. delimiter .. "]+)") do
        table.insert(ret, substr)
    end
    return ret
end

-- Implementation for patterns repeated at least twice
local function is_violating_at_least_twice(n)
    local s = tostring(n)
    local len = #s
    for i = 1, math.floor(len / 2) do
        if len % i == 0 then
            local pattern = string.sub(s, 1, i)
            local num_repetitions = len / i
            if num_repetitions >= 2 then
                local repeated = string.rep(pattern, num_repetitions)
                if s == repeated then
                    return true
                end
            end
        end
    end
    return false
end

-- Implementation for patterns repeated exactly twice
local function is_violating_exactly_twice(n)
    local s = tostring(n)
    local len = #s
    if len % 2 ~= 0 then
        return false
    end
    local half = len / 2
    local first_half = string.sub(s, 1, half)
    local second_half = string.sub(s, half + 1)

    if first_half == second_half then
        return true
    end

    return false
end

function is_violating(n)
    if VIOLATION_METHOD == "AT_LEAST_TWICE" then
        return is_violating_at_least_twice(n)
    elseif VIOLATION_METHOD == "EXACTLY_TWICE" then
        return is_violating_exactly_twice(n)
    else
        error("Invalid VIOLATION_METHOD: " .. tostring(VIOLATION_METHOD))
    end
end

function sum_violating_ids_in_range(start_num, end_num)
    local total = 0
    for i = start_num, end_num do
        if is_violating(i) then
            total = total + i
        end
    end
    return total
end

function Main()
    os.execute('clear')
    local file = io.open('inputdata.txt', 'r')
    if not file then
        print("Error: could not open inputdata.txt")
        return
    end
    local data = file:read('*all')
    file:close()

    local ranges_str = split(data, ',')
    local total_violating_sum = 0

    for _, range_str in ipairs(ranges_str) do
        print("Processing range: " .. range_str)
        local range_parts = split(range_str, '-')
        if #range_parts == 2 then
            local start_num = tonumber(range_parts[1])
            local end_num = tonumber(range_parts[2])
            if start_num and end_num then
                total_violating_sum = total_violating_sum + sum_violating_ids_in_range(start_num, end_num)
            end
        end
    end

    print(total_violating_sum)
end

Main()
