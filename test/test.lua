-- lua require 路径
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../src/?.lua;".. package.path

local LibTableFormat = require "table_format"
local LibStringSearch = require "string_search"

local l_FindClass = LibStringSearch:new({"张三", "李四", "zlf"})

local sMainStr = "张三hhhhzlf李四zzzz"

local tbResults = l_FindClass:find_all(sMainStr)
print("3333333333333333333 ", LibTableFormat(tbResults))
local sMainStr = l_FindClass:replace(tbResults, sMainStr)
print("3333333333333333333 ", sMainStr)