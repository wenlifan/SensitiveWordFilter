-- lua require 路径
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../src/?.lua;".. package.path

local LibTableFormat = require "table_format"
local LibStringSearch = require "string_search"
local LibSpellingSearch = require "spelling_search"

--[[
-- 字符串过滤
local l_FindClass = LibStringSearch:new({"张三", "李四", "zlf"})

local sMainStr = "张三hhhhzlf李四zzzz"

local tbResults = l_FindClass:find_all(sMainStr)
print("3333333333333333333 ", LibTableFormat(tbResults))
local sMainStr = l_FindClass:replace(tbResults, sMainStr)
print("3333333333333333333 ", sMainStr)
]]

-- 字符串转拼音
LibSpellingSearch:init()
-- local tbR = LibSpellingSearch:get_pin_yin('阿里山', 0)
-- print(tbR)

-- tbR = LibSpellingSearch:get_first_pin_yin('阿里山', 0)
-- print(tbR)

-- tbR = LibSpellingSearch:get_all_pin_yin("传", 0)
-- print(LibTableFormat(tbR))

-- tbR = LibSpellingSearch:get_pin_yin_in_list_for_name("欧阳一一", 0)
-- print(LibTableFormat(tbR))
-- 
-- tbR = LibSpellingSearch:get_pin_yin_in_list_for_name("单一一", 0)
-- print(LibTableFormat(tbR))

tbR = LibSpellingSearch:get_pin_yin("单一一sss", 0)
print(tbR)
