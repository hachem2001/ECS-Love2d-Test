local utigo = {}

utigo.point = {
	__add = function(op1, op2)
		if getmetatable(op2)==getmetatable(op1) then
			return utigo.segment:new(op1, op2)
		else
			error("Wrong addition of points")
		end
	end,
}

function utigo.point:new(x, y)
	local m = {x, y}
	setmetatable(m, utigo.point)
	return m
end

utigo.segment = {
	__mul = function(op1, op2)
		local r, m = utigo.get_intersection_segments(op1.A[1], op1.A[2], op1.B[1], op1.B[2], op2.A[1], op2.A[2], op2.B[1], op2.B[2])
		local c = utigo.point:new(m[1], m[2])
		return {r, c}
	end,
}

function utigo.segment:new(pointa, pointb)
	local m = {A=pointa, B=pointb}
	setmetatable(m, utigo.segment) 
	return m
end

--
--

---------------------------------------------------------------
-- Functions --------------------------------------------------
---------------------------------------------------------------

function utigo.get_line_equation(x1,y1,x2,y2)
	local X,Y = (x2-x1), (y2-y1)
	return X, -Y, (Y*x1 - X*y1)
	-- a, b, c
	-- equation : ay + bx + c = 0
end

function utigo.get_intersection(eq1 , eq2)
	local a1,b1,c1 = unpack(eq1)
	local a2,b2,c2 = unpack(eq2)
	local intx = (-(c1-((a1*c2)/a2)))/(b1-a1*(b2/a2))
	local inty = (-b1*intx-c1)/a1
	return intx, inty
end

function utigo.get_intersection_segments(xa1,ya1,xa2,ya2, xb1, yb1, xb2, yb2)
	local m = {utigo.get_intersection( {utigo.get_line_equation(xa1,ya1,xa2,ya2)}, {utigo.get_line_equation(xb1, yb1, xb2, yb2)} ) }
	local r = math.abs(m[1]-xa1)+math.abs(m[1]-xa2)<=(math.abs(xa1-xa2)) and math.abs(m[1]-xb1)+math.abs(m[1]-xb2)<=(math.abs(xb1-xb2))
	
	print( m )
	return r , m
end

--------------------------------------------------------------------
-------------------------Drawing Stuff -----------------------------
--------------------------------------------------------------------

function utigo.drawpoints(...)
	local args = {...}
	for k,v in pairs(args) do
		love.graphics.points(v[1],v[2])
	end
end

function utigo.drawsegment(...)
	local args = {...}
	for k,v in pairs(args) do
		love.graphics.line(v.A[1], v.A[2], v.B[1], v.B[2])
	end
end
-------------------------------
-------------------------------

return utigo