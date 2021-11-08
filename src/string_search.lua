--[[
    Author: zlf
    Date: 2021.11.08
    Note: 字符串的敏感词过滤
]]
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

return StringSearch