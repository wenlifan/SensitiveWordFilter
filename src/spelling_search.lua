--[[
    Author: zlf
    Date: 2021.11.08
    Note: 将字符串转换成拼音
]]
local LibBuildTrie = require "build_trie"
local LibSpelling = require "spelling"
local LibStringSplit = require "string_split"
local LibTableFormat = require "table_format"

local SpellingSearch = {}

function SpellingSearch:init()
    self.m_py_name = LibSpelling.py_name
    self.m_py_show = LibSpelling.py_show
    self.m_py_index = LibSpelling.py_index
    self.m_py_data = LibSpelling.py_data
    self.m_py_words_key = LibSpelling.py_words_key
    self.m_py_words_index = LibSpelling.py_words_index
    self.m_word_py = LibSpelling.word_py
    self.m_search = nil
end

function SpellingSearch:init_py_words()
    if self.m_search == nil then
        local tbSearch = LibBuildTrie:new()
        tbSearch:set_key_words(self.m_py_words_key)
        self.m_search = tbSearch
    end
end

function SpellingSearch:find_all(sText)
    local tbPtr = nil
    local tbList = {}

    local tbCharArray = LibStringSplit(sText)
    for nIndex, nT in  ipairs(tbCharArray) do
        local tbTN
        if (not tbPtr) then
            tbTN = self.m_search._tbFirst:try_get_value(nT)
        else
            tbTN = tbPtr:try_get_value(nT)
            if(not tbTN) then
                tbTN = self.m_search._tbFirst:try_get_value(nT)
            end
        end

        if (tbTN) then
            if(tbTN.m_bEnd) then
                -- return self._tbKeywords[tbTN.m_tbResults[1]]
                for _, sValue in ipairs(tbTN.m_tbResults) do
                    -- table.insert(tbList, self._tbKeywords[sValue])
                    table.insert(tbList, {
                        ["keyword"] = self.m_search._tbKeywords[sValue], 
                        ["success"] = true, 
                        ["end"] = nIndex, 
                        ["start"] = nIndex + 1 - #LibStringSplit(self.m_search._tbKeywords[sValue]), 
                        ["index"] = self.m_search._tbIndexs[sValue]
                    })
                end
            end
        end
        tbPtr = tbTN
    end
    return tbList
end

function SpellingSearch:get_pin_yin_list(sText, nTone)
    nTone = nTone or 0
    self:init_py_words()

    if nTone ~= 1 then
        nTone = 0
    end
    local tbList = {}
    local nPindex = -1
    local tbPos = self:find_all(sText)

    for _, nP in ipairs(tbPos) do
        if(nP["start"] > nPindex) then
            -- for nI in ipairs(nP[keyword])
            for nI = 1, #LibStringSplit(nP['keyword']) do
                -- print(nP['index'])
                -- print(self.m_py_words_index[nP['index']])
                -- print(self.m_word_py[nI + self.m_py_words_index[nP['index']]])

                tbList[nI + nP["start"] - 1] = self.m_py_show[self.m_word_py[nI + self.m_py_words_index[nP['index']]]+ nTone + 1]
            end
            nPindex = nP['end']
        end
    end

    local tbCharArray = LibStringSplit(sText)
    for nI, nC in ipairs(tbCharArray) do
        if not tbList[nI] then
            if (nC >= 0x3400 and nC <= 0x9fd5) then
                local nIndex = nC - 0x3400
                local nStart = self.m_py_index[nIndex+1]
                local nEnd = self.m_py_index[nIndex+1+1]
                if (nEnd > nStart) then
                    -- print(self.m_py_data[nStart+1])
                    -- print(self.m_py_show[self.m_py_data[nStart] + nTone + 1])
                    tbList[nI] = self.m_py_show[self.m_py_data[nStart+1] + nTone + 1]
                end
            end
        end
    end

    return tbList
end

function SpellingSearch:get_pin_yin(sText, nTone)
    nTone = nTone or 0
    if nTone ~= 1 then
        nTone = 0
    end

    local tbList = self:get_pin_yin_list(sText, nTone)
    local sPy = table.concat(tbList)
    
    return sPy
end

function SpellingSearch:get_first_pin_yin(sText, nTone)
    nTone = nTone or 0
    if nTone ~= 1 then
        nTone = 0
    end

    local tbList = self:get_pin_yin_list(sText, nTone)
    local tbTemp = {}
    for _, sV in ipairs(tbList) do
        table.insert(tbTemp, string.sub(sV, 1,1))
    end

    local sPy = table.concat(tbTemp)
    return sPy
end

function SpellingSearch:get_all_pin_yin(sText, nTone)
    nTone = nTone or 0
    if nTone ~= 1 then
        nTone = 0
    end

    local tbCharArray = LibStringSplit(sText)

    local nIdx = tbCharArray[1]
    local tbList = {}
    if (nIdx >= 0x3400 and nIdx <= 0x9fd5) then
        local nIndex = nIdx - 0x3400
        local nStart = self.m_py_index[nIndex + 1]
        local nEnd = self.m_py_index[nIndex + 1 + 1]
        if (nEnd > nStart) then
            for nI = nStart, nEnd-1 do
                -- table.insert(tbList, self.m_py_show[self.m_py_data[nI+1] + nTone + 1])
                tbList[self.m_py_show[self.m_py_data[nI+1] + nTone + 1]] = self.m_py_show[self.m_py_data[nI+1] + nTone + 1]
            end
        end
    end
    return tbList
end

function SpellingSearch:get_pin_yin_in_list_for_name(sName, nTone)
    nTone = nTone or 0
    if nTone ~= 1 then
        nTone = 0
    end

    local tbList = {}
    
    -- 复姓检查
    if (string.len(sName) > 6) then
        local sXing = string.sub(sName, 1, 6)
        if (self.m_py_name[sXing]) then
            local tbIndex = self.m_py_name[sXing]
            for _, nIndex in ipairs(tbIndex) do
                table.insert(tbList, self.m_py_show[nIndex + nTone + 1])
            end

            local sMing = string.sub(sName, 7, string.len(sName))
            local tbMpy = self:get_pin_yin_list(sMing, nTone)
            for _, nPy in ipairs(tbMpy) do
                table.insert(tbList, nPy)
            end
    
            return tbList
        end
    end

    local tbList = {}
    -- local tbCharArray = LibStringSplit(sText)
    local sXing = string.sub(sName, 1, 3)
    if (self.m_py_name[sXing]) then
        local tbIndex = self.m_py_name[sXing]
        for _, nIndex in ipairs(tbIndex) do
            table.insert(tbList, self.m_py_show[nIndex + nTone + 1])
        end
    end

    if string.len(sName) > 3 then
        local sMing = string.sub(sName, 4, string.len(sName))
        local tbMpy = self:get_pin_yin_list(sMing, nTone)
        for _, nPy in ipairs(tbMpy) do
            table.insert(tbList, nPy)
        end
    end

    return tbList
end

return SpellingSearch