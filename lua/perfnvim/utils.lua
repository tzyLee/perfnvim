local utils = {}

local quotepattern = '(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])'
function utils.quote(s)
    return s:gsub(quotepattern, "%%%1")
end

return utils
