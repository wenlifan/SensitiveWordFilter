--[[
    Author: zlf
    Date: 2021.11.05
    Note: 构建 trie 树
]]
local LibStringSplit = require "string_split"
local TrieNode = {}

function TrieNode:new()
    local TbNew = {}
    TbNew.m_nIndex = 0
    TbNew.m_nIndex = 0
    TbNew.m_nLayer = 0
    TbNew.m_bEnd = false
    TbNew.m_nChar = 0        -- 将字符转为数字保存(多字节数据)
    TbNew.m_tbResults = {}   -- 列表
    TbNew.m_tbValues = {}    -- 字典
    TbNew.m_pFailure = nil
    TbNew.m_pParent = nil

    function TbNew:add(nChar)
        if self.m_tbValues[nChar] then
            return self.m_tbValues[nChar]
        end
    
        local tbNode = TrieNode:new()
        tbNode.m_pParent = self
        tbNode.m_nChar = nChar
        self.m_tbValues[nChar] = tbNode
    
        return tbNode
    end
    
    function TbNew:set_results(nIndex)
        if self.m_bEnd == false then
            self.m_bEnd = true
        end
    
        table.insert(self.m_tbResults,nIndex)
    end

    return TbNew
end



local TrieNode2 = {}
function TrieNode2:new()
    local TbNew = {}
    TbNew.m_bEnd = false
    TbNew.m_tbResults = {}
    TbNew.m_tbValues = {}
    TbNew.m_nMinflag = 0xffff
    TbNew.m_nMaxflag = 0

    function TbNew:add(nChar, tbNode)
        if(self.m_nMinflag > nChar) then
            self.m_nMinflag = nChar
        end
        
        if (self.m_nMaxflag < nChar) then
            self.m_nMaxflag = nChar
        end
    
        self.m_tbValues[nChar] = tbNode
    end
    
    function TbNew:set_results(nIndex)
        if(self.m_bEnd == false) then
            self.m_bEnd = true
        end
    
        local bFlag = false
        for _, v in ipairs(self.m_tbResults) do
            if v == nIndex then
                bFlag = true
                break
            end
        end
        if not bFlag then
            table.insert(self.m_tbResults,nIndex)
        end
    end
    
    function TbNew:hase_key(nChar)
        return self.m_tbValues[nChar]
    end
    
    function TbNew:try_get_value(nChar)
        if (self.m_nMinflag <= nChar and nChar <= self.m_nMaxflag) then
            if self.m_tbValues[nChar] then
                return self.m_tbValues[nChar]
            end
        end
        return nil
    end

    return TbNew
end



local TrieSearch = {}
function TrieSearch:new()
    local TbNew = {}
    TbNew._tbFirst = {}            -- 字典
    TbNew._tbKeywords = {}         -- 数组
    TbNew._tbIndexs = {}           -- 数组
    function TbNew:set_key_words(tbKeyWords)
        self._tbKeywords = tbKeyWords
        self._tbIndexs = {}
    
        for k in ipairs(tbKeyWords) do
            table.insert(self._tbIndexs, k)
        end
    
        local tbRoot = TrieNode:new()
        local tbAllNodeLayer = {}   -- 字典
    
        for nKey, sStr in ipairs(self._tbKeywords) do
            local tbP = LibStringSplit(sStr)
            local tbNd = tbRoot
    
            for nAKey, nAChar in ipairs(tbP) do
                tbNd = tbNd:add(nAChar)
                if(tbNd.m_nLayer == 0) then
                    tbNd.m_nLayer = nAKey
    
                    if tbAllNodeLayer[tbNd.m_nLayer] then
                        table.insert(tbAllNodeLayer[tbNd.m_nLayer], tbNd)
                    else
                        tbAllNodeLayer[tbNd.m_nLayer] = {}
                        table.insert(tbAllNodeLayer[tbNd.m_nLayer], tbNd)
                    end
    
                end
            end
            tbNd:set_results(nKey)
        end
    
        local tbAllNode = {}        -- 有序数组
        table.insert(tbAllNode, tbRoot)
    
        for _, tbVNode in pairs(tbAllNodeLayer) do
            for _, tbVVNode in ipairs(tbVNode) do
                table.insert(tbAllNode, tbVVNode)
            end
        end
        tbAllNodeLayer = nil
    
        -- 失败指针构建
        for nKey , tbNd in ipairs(tbAllNode) do
            -- nKey == 1 指向 tbRoot
            if nKey ~= 1 then
                tbNd.m_nIndex = nKey
                
                local tbR = tbNd.m_pParent.m_pFailure
                local tbC = tbNd.m_nChar
    
                while( tbR and (not tbR.m_tbValues[tbC])) do
                    tbR = tbR.m_pFailure
                end
    
                if (not tbR) then
                    tbNd.m_pFailure = tbRoot
                else
                    tbNd.m_pFailure = tbR.m_tbValues[tbC]
                    for k, v in ipairs(tbNd.m_pFailure.m_tbResults) do
                        tbNd:set_results(v)
                    end
                end
            end
        end
        tbRoot.m_pFailure = tbRoot
    
        local tbAllNode2 = TrieNode2:new()
        for _, _ in ipairs(tbAllNode) do
            table.insert(tbAllNode2, TrieNode2:new())
        end
    
        for nI, tbNode in ipairs(tbAllNode2) do
            local tbOldNode = tbAllNode[nI]
            local tbNewNode = tbAllNode2[nI]
    
            for nChar, nValue in pairs(tbOldNode.m_tbValues) do
                local nIndex = tbOldNode.m_tbValues[nChar].m_nIndex
                tbNewNode:add(nChar, tbAllNode2[nIndex]) 
            end
    
            for nIndex in ipairs(tbOldNode.m_tbResults) do
                local tbItem = tbOldNode.m_tbResults[nIndex]
                tbNewNode:set_results(tbItem)
            end
    
            tbOldNode=tbOldNode.m_pFailure
    
            while(tbOldNode ~= tbRoot) do
                for nIndex in pairs(tbOldNode.m_tbValues) do
                    if (not tbNewNode:hase_key(nIndex)) then
                        local nIndex = tbOldNode.m_tbValues[nIndex].m_nIndex
                        tbNewNode:add(nIndex, tbAllNode2[nIndex])
                    end
                end
    
                for nIndex, tbItem in ipairs(tbOldNode.m_tbResults) do
                    tbNewNode:set_results(tbItem)
                end
    
                tbOldNode = tbOldNode.m_pFailure
            end
        end
    
        tbAllNode = nil
        root = nil
    
        self._tbFirst = tbAllNode2[1]
    end
    
    function TbNew:find_first(sText)
        local tbPtr = nil
        local tbCharArray = LibStringSplit(sText)
    
        for nIndex, nT in ipairs(tbCharArray) do
            local tbTN
            if (not tbPtr) then
                tbTN = self._tbFirst:try_get_value(nT)
            else
                tbTN = tbPtr:try_get_value(nT)
                if(not tbTN) then
                    tbTN = self._tbFirst:try_get_value(nT)
                end
            end
    
            if (tbTN) then
                if(tbTN.m_bEnd) then
                    return self._tbKeywords[tbTN.m_tbResults[1]]
                end
            end
            tbPtr = tbTN
        end
    
        return nil
    end

    function TbNew:find_all(sText)
        local tbPtr = nil
        local tbList = {}

        local tbCharArray = LibStringSplit(sText)
        for nIndex, nT in  ipairs(tbCharArray) do
            local tbTN
            if (not tbPtr) then
                tbTN = self._tbFirst:try_get_value(nT)
            else
                tbTN = tbPtr:try_get_value(nT)
                if(not tbTN) then
                    tbTN = self._tbFirst:try_get_value(nT)
                end
            end
    
            if (tbTN) then
                if(tbTN.m_bEnd) then
                    -- return self._tbKeywords[tbTN.m_tbResults[1]]
                    for _, sValue in ipairs(tbTN.m_tbResults) do
                        table.insert(tbList, self._tbKeywords[sValue])
                    end
                end
            end
            tbPtr = tbTN
        end
        return tbList
    end

    return TbNew
end

--[[
local l_FindClass = TrieSearch:new()
l_FindClass:set_key_words({"张三", "李四", "zlf"})

local sMainStr = "张三hhhhzlf李四zzzz"
-- local sResults = l_FindClass:find_first(sMainStr)

local tbResults = l_FindClass:find_all(sMainStr)
print("3333333333333333333 ", sMainStr)
]]

return TrieSearch