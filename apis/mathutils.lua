local mathutils = {}
--

--
--> Range utils ----------------------------------------------------------------------------------------------------------------------
--
function mathutils.in_error_range(x, y, e) -- checks if -e<x-y<e aka : close to being equal
	return mathutils.abs(x-y)<e
end

function mathutils.distance(x, y, x2, y2)
	return ((x-x2)^2+(y-y2)^2)^.5
end

function mathutils.getmagnitude(...)
	local args = {...}
	local s = 0
	for k,v in pairs(args) do
		s=s+v^2
	end
	return s^0.5
end

function mathutils.sign(x)
	return x<0 and -1 or 1
end
--
return mathutils