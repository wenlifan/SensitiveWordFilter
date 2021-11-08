--[[
    Author: zlf
    Date: 2021.11.05
    Note: 将字符串按UTF8的编码要求拆分字符串, 返回拆分后的数组。
]]

-- UTF8中, 下一个字符占用几个字节
local function utf8_char_len(bBit)
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

-- UTF8 转 Unicode
local function utf8_to_unicode(tbUTF8Array)
    local bB1, bB2, bB3, bB4, bB5, bB6 = tbUTF8Array[1],tbUTF8Array[2],tbUTF8Array[3],tbUTF8Array[4],tbUTF8Array[5],tbUTF8Array[6]

    local bUnic = 0x0;
    local nLen = #tbUTF8Array
    local tbResults = {}
    if nLen == 1 then
        tbResults[1] = bB1
        return {bB1}
    elseif nLen == 2 then
        if ((bB2 & 0xE0) ~= 0x80) then
            return tbResults
        end
        tbResults[1] = (bB1 << 6) + (bB2 & 0x3F)
        tbResults[2] = (bb1 >> 2) & 0x07

        return tbResults
    elseif nLen == 3 then
        if ( ((bB2 & 0xC0) ~= 0x80) or ((bB3 & 0xC0) ~= 0x80) ) then
            return tbResults
        end

        tbResults[1] = (bB2 << 6) + (bB3 & 0x3F)
        tbResults[2] = (bB1 << 4) + ((bB2 >> 2) & 0x0F)

        return tbResults
    elseif nLen == 4 then
        if ( ((bB2 & 0xC0) ~= 0x80) or ((bB3 & 0xC0) ~= 0x80)
                or ((bB4 & 0xC0) ~= 0x80) ) then
            return tbResults
        end
        tbResults[1] = (bB3 << 6) + (bB4 & 0x3F);
        tbResults[2] = (bB2 << 4) + ((bB3 >> 2) & 0x0F);
        tbResults[3] = ((bB1 << 2) & 0x1C)  + ((bB2 >> 4) & 0x03);

        return tbResults
    elseif nLen == 5 then
        if ( ((bB2 & 0xC0) ~= 0x80) or ((bB3 & 0xC0) ~= 0x80)
        or ((bB4 & 0xC0) ~= 0x80) or ((bB5 & 0xC0) ~= 0x80) ) then
            return tbResults
        end
        tbResults[1] = (bB4 << 6) + (bB5 & 0x3F);
        tbResults[2] = (bB3 << 4) + ((bB4 >> 2) & 0x0F);
        tbResults[3] = (bB2 << 2) + ((bB3 >> 4) & 0x03);
        tbResults[4] = (bB1 << 6);

        return tbResults
    elseif nLen == 6 then
        if ( ((b2 & 0xC0) ~= 0x80) or ((b3 & 0xC0) ~= 0x80)
        or ((b4 & 0xC0) ~= 0x80) or ((b5 & 0xC0) ~= 0x80)
        or ((b6 & 0xC0) ~= 0x80) ) then
            return tbResults
        end
        tbResults[1] = (b5 << 6) + (b6 & 0x3F);
        tbResults[2] = (b5 << 4) + ((b6 >> 2) & 0x0F);
        tbResults[3] = (b3 << 2) + ((b4 >> 4) & 0x03);
        tbResults[4] = ((b1 << 6) & 0x40) + (b2 & 0x3F);
        return tbResults
    else
        return tbResults
    end
end

-- 将中文转换为二进制 utf8
local function string_to_bit_array_utf8(sStr)
    local nLen = string.len(sStr)
    local tbBinArray = {}
    local nKey = 1
    while(nKey <= nLen) do
        local bTemp = string.byte(sStr, nKey)
        -- UTF8 编码, 第一个字节的前几位1的数量决定了占用字节的数量
        local bNum = utf8_char_len(bTemp)
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

-- 将字符串转换成二进制 unicode
local function string_to_bit_array_unicode(sStr)
    local nLen = string.len(sStr)
    local tbBinArray = {}
    local nKey = 1
    while(nKey <= nLen) do
        local bTemp = string.byte(sStr, nKey)
        -- UTF8 编码, 第一个字节的前几位1的数量决定了占用字节的数量
        local bNum = utf8_char_len(bTemp)
        local tbBtemp = {}
        for i = 0, bNum - 1 do
            table.insert(tbBtemp, string.byte(sStr, nKey+i))
        end
        local tbBtemp2 = utf8_to_unicode(tbBtemp)
        local oXData = 0x0
        local bMove = false
        -- 使用大端
        for i = #tbBtemp2, 1, -1 do
            if bMove then
                oXData = oXData << 8
            end
            bMove = true
            
            oXData = oXData + (tbBtemp2[i] & 0xFF)
        end
        table.insert(tbBinArray, oXData)
        nKey = nKey + bNum
    end
    return tbBinArray
end

return string_to_bit_array_unicode

--[[
local nR = utf8_char_len(0xF0) -- 1111 0000
print(nR)

print("----------------------------")

local nR = utf8_char_len(0xE0) -- 1110 0000
print(nR)

local nR = utf8_char_len(0xEF) -- 1110 1111
print(nR)

print("----------------------------")

local nR = utf8_char_len(0xC0) -- 1100 0000
print(nR)

local nR = utf8_char_len(0xCF) -- 1100 0000
print(nR)

print("----------------------------")

local nR = utf8_char_len(0x7F) -- 1
print(nR)

print("----------------------------")
]]

--[[
local bTemp = string_to_bit_array_unicode("严s~!@")
for _, v in ipairs(bTemp) do
    local temp = string.format("%X", v)
    print(type(temp))
    print(type(v))
    print(temp)
end

local bTemp = string_to_bit_array_utf8("严s~!@")
for _, v in ipairs(bTemp) do
    local temp = string.format("%X", v)
    print(type(temp))
    print(type(v))
    print(temp)
end
]]