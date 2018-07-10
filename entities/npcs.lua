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

local DELAY = 0.001;
local delay = DELAY;
local shooting_angle = 0;
local Tau = 2*math.pi;

function npcs:update(dt)
	shooting_angle = (shooting_angle + 100*Tau*dt)%(Tau);
	delay = delay - dt;
	if delay < 0 then
		local player = ECS.entities["player"]
		for k,v in pairs(self.npcs) do
--			local direction = vector(player.body.pos.x - v.body.pos.x, player.body.pos.y- v.body.pos.y)%shooting_angle;
			for i=1,2 do
				shooting_angle = (shooting_angle + 100*Tau*dt)%(Tau);
				local direction = vector(1, 0)%shooting_angle;
				ECS:new_entity("pushpellets", {pos = vector(v.body.pos.x, v.body.pos.y),
								direction=direction,
								name = 'npcs', id = k, giver_body_id = v.body_id, avoid_type=true})
			end
		end
		delay = DELAY;
	end
end

function npcs:draw()
	for k,v in pairs(self.npcs) do
		love.graphics.setColor(1,1,1,1)
		sdraw.rectangle("fill", v.body.pos.x-v.body.w/2, v.body.pos.y-v.body.h/2, v.body.w, v.body.h) -- Smart draw won't render this if it's away from camera. more handy
		--love.graphics.rectangle("fill", v.body.pos.x-v.body.w/2, v.body.pos.y-v.body.h/2, v.body.w, v.body.h)
	end
end

return npcs;