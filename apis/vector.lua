local vector = {}

function vector.__add(op1, op2)
	local n = {}
	if #op1>=#op2 then
		for k,v in pairs(op1) do
			n[k] = v+(op2[k] or 0)
		end
	else
		for k,v in pairs(op2) do
			n[k] = v+(op1[k] or 0)
		end
	end
	return setmetatable(n, vector)
end

function vector.__sub(op1, op2)
	return vector.__add(op1, -op2)
end

function vector.__unm(op1)
	local n = {}
	for k,v in pairs(op1) do
		n[k] = -v
	end
	return setmetatable(n, vector)
end

function vector.__mul(op1, op2)
	if type(op1)=="number" then
		op1,op2 = op2,op1
	end
	if type(op2) == "number" then
		local n = {}
		for k,v in pairs(op1) do
			n[k] = v*op2
		end
		return setmetatable(n, vector)
	end
	local s = 0
	if #op1>#op2 then
		for k,v in pairs(op1) do
			s = s + v*(op2[k] or 0)
		end
	else
		for k,v in pairs(op2) do
			s = s + v*(op1[k] or 0)
		end
	end
	return s
end

function vector.__div(op1, op2)
	if type(op1)=="number" then
		op1,op2 = op2,op1
	end
	if type(op2) == "number" then
		return op1*(1/op2)
	else
		return math.acos((op1*op2)/vector.getlength(op1)/vector.getlength(op2))
	end
end

function vector.__pow(op1, op2)
	if type(op1)=="number" then
		op1,op2 = op2,op1
	end
	local m = type(op2)=="number" and op2 or vector.getlength(op2)
	return (op1/vector.getlength(op1))*m
end

local m = {x=1, y=2, z=3, w=4, r=1, g=2, b=3, a=4} -- basic ways of requesting an element from 
function vector.__index(op1, ind)
	return rawget(op1, m[ind]) or error("Attempt to reference element "..ind.." of vector, inexistant.");
end

function vector.__tostring(op1)
	return "x:"..op1[1]..",y:"..op1[2];
end

function vector:new(...)
	local args = {...}
	local m = {}
	for k,v in pairs(args) do
		m[k] = v
	end
	return setmetatable(m, self)
end

function vector.getrotationdirection(vec1, vec2) -- only works if both vectors are 2D. + means anti-clockwise and - means clockwise
	if not (#vec1==2 and #vec2==2) then return 0 end
	return vec1[1]*vec2[2]-vec1[2]*vec2[1]
end

function vector.getlength(vec1)
	local s = 0
	for k,v in pairs(vec1) do
		s = s + v^2
	end
	return s^.5
end

--
return vector