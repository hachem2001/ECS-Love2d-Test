local ffi = require "ffi"
ffi.cdef[[
	typedef struct {double x, y;} vector_t;
]]
local vector_mt = {}
local vector -- forward declare vector

function vector_mt.__add(op1, op2)
	return vector(op1.x+op2.x, op1.y+op2.y)
end

function vector_mt.__sub(op1, op2)
	return vector(op1.x-op2.x, op1.y-op2.y)
end

function vector_mt.__unm(op1)
	return vector(-op1.x, -op1.y)
end

function vector_mt.__mul(op1, op2)
	if type(op1)=="number" then
		op1,op2 = op2,op1
	end
	if type(op2) == "number" then
		return vector(op2*op1.x, op2*op1.y)
	end
	return op1.x*op2.x + op1.y*op2.y;
end

function vector_mt.__div(op1, op2)
	if type(op1)=="number" then
		op1,op2 = op2,op1
	end
	if type(op2) == "number" then
		return vector(op1.x/op2, op1.y/op2)
	else
		return math.acos((op1*op2)/(#op1*#op2))
	end
end

function vector_mt.__pow(op1, op2)
	if type(op1)=="number" then
		op1,op2 = op2,op1
	end
	local m = type(op2)=="number" and op2 or #op2
	return (op1/#op1)*m
end

function vector_mt.__mod(op1, op2)
	if type(op2) == "number" then -- rotate vector by op2 radians
		return vector(op1.x*math.cos(op2) - op1.y*math.sin(op2), op1.x*math.sin(op2) + op1.y*math.cos(op2))
	end
end

function vector_mt.__tostring(op1)
	return "x:"..op1.x..",y:"..op1.y;
end

function vector_mt.__len(op1)
	return (op1.x^2 + op1.y^2)^0.5;
end

--
vector = ffi.metatype("vector_t", vector_mt)

return vector;