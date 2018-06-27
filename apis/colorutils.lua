local colorutils = {}
--

--[[-- Notes
	* You can still use tbl.[r, g, b or a] since I used color.__index to do so
	* calling a color is like follows : [ color(col, period, curr)
		- It shifts a color to another linearly in time
		- You need to add 3 parameters : the projected color, the period and the current position in the period
		- if period is 5 and curr is 3, you'd be in the factor is 3/5.
		- The transformation is linear, but twingeling with curr or period outside in the using code can make it different.
--]]--

local keys = {r=1, g=2, b=3, a=4}

function colorutils.__index(col, key)
	
	return col[keys[key]]
end

function colorutils.__call(col1, col2, speed) -- col2,speed → color,speed of transition (ex : dt)
	local factor = speed
	local r, g, b, a = col1[1] + (col2[1]-col1[1])*factor, col1[2] + (col2[2]-col1[2])*factor, col1[3] + (col2[3]-col1[3])*factor, col1[4] + (col2[4]-col1[4])*factor
	
	return colorutils:new(r, g, b, a)
end

function colorutils.__add(col1, num)
	for k,v in pairs(col1) do col1[k] = (v+num) end
end

function colorutils:copy(color)
	return setmetatable({color[1] or 0,color[2] or 0,color[3] or 0, color[4] or 0}, colorutils)
end

function colorutils:neww(r, g, b, a)
	local r, g, b, a = r or 0, g or 0, b or 0, a or 0
	if type(r) == "table" then
		r, g, b, a = r[1], r[2], r[3], r[4]
	end
	return setmetatable({r/255, g/255, b/255, a/255}, self)
end

function colorutils:new(r, g, b, a)
	local r, g, b, a = r or 0, g or 0, b or 0, a or 0
	if type(r) == "table" then
		r, g, b, a = r[1], r[2], r[3], r[4]
	end
	return setmetatable({r, g, b, a}, self)
end

--
return colorutils