local _ = math

math = {}

local meta = {}

meta.__index = function(source, index)
	return _[index]
end

meta.__newindex = function(source, index, value) 
	printstream("Internal Error", "Cannot add functions to the math library")
end

math.Round = function(Num, Decimals)
	return math.floor((Num)*(10 ^Decimals) + 0.5)/(10^Decimals)
end

math.Sine = {} -- Placeholder.

setmetatable(math, meta)