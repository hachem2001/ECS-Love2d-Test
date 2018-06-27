local positions = {}
positions.positions = {};

function positions:add(x, y)
	local m = {x or 0, y or 0};
	local index = #self.positions+1;
	self.positions[index] = m;
	return index, m;
end

function positions:destroy(id) -- returns a pos by id. This is okay to do, but a very more
	-- efficient way of doing this is by indexing the position 
	table.remove(self.positions, id);
end

function positions:update(dt)
	for k,v in pairs(self.positions) do
		v[1] = v[1] + 100*dt;
	end
end

return positions;