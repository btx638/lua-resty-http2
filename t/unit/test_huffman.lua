-- Copyright Alex Zhang (tokers)

package.path = "./lib/?.lua;;"

local huffenc = require "resty.http2.huff_encode"
local huffdec = require "resty.http2.huff_decode"

local assert = assert
local concat = table.concat
local char = string.char

local function test(str, lower)
    local out2 = {}
    local dec_state = huffdec.new_state()
    local out1 = huffenc.encode(str, lower)
    if not out1 then
        return
    end

    local data = concat(out1)

    local ok, err = dec_state:decode(data, out2, true)

    if lower then
        str = str:lower()
    end

    assert(ok, err)
    assert(str == concat(out2), "bad decoded result, \"" .. str ..
                                "\" is expected but got \"" .. concat(out2) ..
                                "\"")
end


test("hello,", false)
test("hello, world", true)
test("hello, 你好世界", false)
test("HELLO, 你好世界", true)
test("abcABC", true)
test("!@#~$%^&*()_+{}:\"01234567890abcdefghijklmnopgrstuvwxyzABCDEFGHIJKLMNOPGRSTUVWXYZ", false)
test("!@#~$%^&*()_+{}:\"01234567890abcdefghijklmnopgrstuvwxyzABCDEFGHIJKLMNOPGRSTUVWXYZ", true)

local mid = {}
for i = 0, 255 do
    mid[#mid + 1] = char(i)
end

test(concat(mid), false)
test(concat(mid), true)
