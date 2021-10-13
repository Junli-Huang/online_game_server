
function string.split(input, delimiter, plain)
    input = tostring(input)
    delimiter = tostring(delimiter)
    plain = plain or false
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, plain) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end


function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end


function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end


function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end


local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end


function string.urldecode(input)
    input = string.gsub (input, "+", " ")
    input = string.gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
    input = string.gsub (input, "\r\n", "\n")
    return input
end


function string.utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end


function string.fromhex(str)
    return str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end)
end


function string.tohex(str)
    return str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end)
end