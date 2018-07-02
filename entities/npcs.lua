local npcs = {}
npcs.npcs = {}

function npcs:add(info) -- adds the NPCS
	local m = {}
	local index = #self.npcs+1
	m.body_id, m.body = ECS:new_component("body", 'npcs', index, info.x or 32, info.y or 32, info.w or 32, info.h or 32, info.m, info.friction, info.bounciness)
	self.npcs[index] = m;
end

function npcs:destroy(npc_id)
	local m = self.npcs[npc_id];
	ECS:queue_component_destroy("body", self.npcs[npc_id].body_id);
	table.remove(self.npcs, npc_id);
end

--
--> Events
--

function npcs:update(dt)
	for k,v in pairs(self.npcs) do
		--v.body.vel[1] = 0;
	end
end

function npcs:draw()
	for k,v in pairs(self.npcs) do
		love.graphics.setColor(1,1,1,1)
		love.graphics.rectangle("fill", v.body.pos[1], v.body.pos[2], v.body.w, v.body.h)
	end
end

return npcs;