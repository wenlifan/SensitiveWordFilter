return function(tbl)
    assert(type(tbl) == "table")
    local str = ""
    local tbl_record = {}
    local function dump_table(t, space, toptable)
        str = str .. ("{\n")
        local keys = {}
        for k in pairs(t) do
            table.insert(keys, k)
        end
        -- table.sort(keys)
        tbl_record[t] = true
        for _,k in ipairs(keys) do
            local v = rawget(t, k)
            local tk = type(k)
            if tk == "number" then
                str = str .. space .. "    [" .. k .. "] = "
            elseif tk == "string" then
                str = str .. space .. "    " .. k .. " = "
            else
                str = str .. "[UNKNOWN: " .. tostring(k) .. "] = "
            end

            local tv = type(v)
            if tv == "number" then
                str = str .. v .. ",\n"
            elseif tv == "string" then
                if v:find('"') then
                    str = str .. "[=[" .. v .. "]=],\n"
                else
                    str = str .. '"' .. v .. '",\n'
                end
            elseif tv == "boolean" then
                str = str .. (v and "true" or "false") .. ",\n"
            elseif tv == "table" then
                if tbl_record[v] then
                    str = str .. "[RECURSIVE TABLE],\n"
                else
                    dump_table(v, space .. "    ")
                end
            else
                str = str .. "[UNKNOWN: " .. tostring(v) .. "],\n"
            end
        end
        str = str .. space .. "}" .. (toptable and "" or ",") .. "\n"
    end
    dump_table(tbl, "", true)
    return str
end