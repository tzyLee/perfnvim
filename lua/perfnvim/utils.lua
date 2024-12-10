local utils = {}

local quotepattern = '(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])'
function utils.quote(s)
    return s:gsub(quotepattern, "%%%1")
end

function utils.reverse(arr)
	local n = #arr+1
	for i = 1, #arr>>1 do
		arr[i], arr[n - i] = arr[n - i], arr[i]
	end
end

return utils
