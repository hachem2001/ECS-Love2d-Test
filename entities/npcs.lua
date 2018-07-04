local npcs = {}
npcs.npcs = {}

local global_id = 0;

function npcs:add(info) -- adds the NPCS
	local m = {}
	local w,h = info.w or 32, info.h or 32
	m.body_id, m.body = ECS:new_component("body", 'npcs', global_id, (info.x or 32)+w/2, (info.y or 32)+h/2, w, h, info.m, info.friction, info.bounciness)
	
	self.npcs[global_id] = m;
	global_id = global_id+1;
end

function npcs:destroy(npc_id)
	local m = self.npcs[npc_id];
	ECS:queue_component_destroy("body", self.npcs[npc_id].body_id);
	self.npcs[npc_id] = nil
end

--
--> Events
--

local DELAY = 0.05;
local delay = DELAY;
function npcs:update(dt)
	delay = delay - dt;
	if delay < 0 then
		local player = ECS.entities["player"]
		for k,v in pairs(self.npcs) do
			ECS:new_entity("pushpellets", {pos = vector:new(v.body.pos[1], v.body.pos[2]),
							direction=vector:new(player.body.pos[1] - v.body.pos[1], player.body.pos[2]- v.body.pos[2]),
							name = 'npcs', id = k, giver_body_id = v.body_id, avoid_type=true})
		end
		delay = DELAY;
	end
end

function npcs:draw()
	for k,v in pairs(self.npcs) do
		love.graphics.setColor(1,1,1,1)
		love.graphics.rectangle("fill", v.body.pos[1]-v.body.w/2, v.body.pos[2]-v.body.h/2, v.body.w, v.body.h)
	end
end

return npcs;