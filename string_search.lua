local LibTableFormat = require "table_format"
local LibBuildTrie = require "build_trie"

local StringSearch = {}
function StringSearch:new(tbShieldLib)
    local tbLibNew = LibBuildTrie:new()
    tbLibNew:set_key_words(tbShieldLib)

    -- 字符串自定义功能
    function tbLibNew:replace(tbText, SReplaceChar)
        for _, sText in ipairs(tbText) do
            SReplaceChar = string.gsub(SReplaceChar, sText, "***", 1)
        end
        return SReplaceChar
    end

    return tbLibNew
end


--[[
local l_FindClass = StringSearch:new({"张三", "李四", "zlf"})

local sMainStr = "张三hhhhzlf李四zzzz"

local tbResults = l_FindClass:find_all(sMainStr)
print("3333333333333333333 ", LibTableFormat(tbResults))
local sMainStr = l_FindClass:replace(tbResults, sMainStr)
print("3333333333333333333 ", sMainStr)
]]