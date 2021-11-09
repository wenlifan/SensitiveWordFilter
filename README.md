# SensitiveWordFilter
AC自动机实现敏感词过滤

### 参考项目(去点星星啦)
https://github.com/toolgood/ToolGood.Words

### 字符串过滤
```
local LibStringSearch = require "string_search"

-- 构建trie树
local l_FindClass = LibStringSearch:new({"张三", "李四", "zlf"})

-- 屏蔽字符查找
local sMainStr = "张三hhhhzlf李四zzzz"
local tbResults = l_FindClass:find_all(sMainStr)

-- 屏蔽字符替换
local sMainStr = l_FindClass:replace(tbResults, sMainStr)
```

### 拼音转换
```
local LibSpellingSearch = require "spelling_search"
LibSpellingSearch:init()
-- 词组转拼音
LibSpellingSearch:get_pin_yin('阿里山', 0)

-- 多音字拼音
LibSpellingSearch:get_all_pin_yin("传", 0)

-- 人名拼音
LibSpellingSearch:get_pin_yin_in_list_for_name("欧阳一一", 0)
LibSpellingSearch:get_pin_yin_in_list_for_name("单一一", 0)
```

### 测试代码运行
```
lua5.3 test/test.lua 
```
