--[[
    Author: zlf
    Date: 2021.11.05
    Note: 将字符串按UTF8的编码要求拆分字符串, 返回拆分后的数组。
]]

-- UTF8中, 下一个字符占用几个字节
local function UTF8CharNum(bBit)
    --[[
    if bBit >= 252 then return 6 end                -- 1111 1100 
    if bBit < 252 and bBit >= 251 then return 5 end -- 1111 1000 ~ 1111 1011
    if bBit < 248 and bBit >= 240 then return 4 end -- 1111 0000 ~ 1111 0111
    if bBit < 240 and bBit >= 224 then return 3 end -- 1110 0000 ~ 1110 1111
    if bBit < 224 and bBit >= 192 then return 2 end -- 1100 0000 ~ 1101 1111
    return 1
    ]]
    if     bBit >= 252 then return 6
    elseif bBit >= 251 then return 5
    elseif bBit >= 240 then return 4
    elseif bBit >= 224 then return 3
    elseif bBit >= 192 then return 2
    else                    return 1 end
end

-- 将中文转换为二进制
local function StringToBitArray(sStr)
    local nLen = string.len(sStr)
    local tbBinArray = {}
    local nKey = 1
    while(nKey <= nLen) do
        local bTemp = string.byte(sStr, nKey)
        -- UTF8 编码, 第一个字节的前几位1的数量决定了占用字节的数量
        local bNum = UTF8CharNum(bTemp)
        local oXData = 0x0
        local bMove = false
        for i = nKey, nKey + bNum - 1 do
            if bMove then
                oXData = oXData << 8
            end
            bMove = true
            local bXtemp = string.byte(sStr, i)
            oXData = oXData + bXtemp
        end
        table.insert(tbBinArray, oXData)
        nKey = nKey + bNum
    end
    return tbBinArray
end

return StringToBitArray

--[[
local nR = UTF8CharNum(0xF0) -- 1111 0000
print(nR)

print("----------------------------")

local nR = UTF8CharNum(0xE0) -- 1110 0000
print(nR)

local nR = UTF8CharNum(0xEF) -- 1110 1111
print(nR)

print("----------------------------")

local nR = UTF8CharNum(0xC0) -- 1100 0000
print(nR)

local nR = UTF8CharNum(0xCF) -- 1100 0000
print(nR)

print("----------------------------")

local nR = UTF8CharNum(0x7F) -- 1
print(nR)

print("----------------------------")
]]

--[[
local bTemp = StringToBitArray("凡")
for _, v in ipairs(bTemp) do
    local temp = string.format("%X", v)
    print(type(temp))
    print(type(v))
    print(temp)
end
]]