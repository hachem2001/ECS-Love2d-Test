local bodies = {}
bodies.bodies = {};

function bodies:add(x, y, w, h) -- adds a rectangle
	local m = {pos=vector:new(x, y), w = w or 1, h = h or 1, vel=vector:new(0,0)}
	local index = #self.bodies+1;
	self.bodies[index] = m;
	return index, m;
end

function bodies:destroy(id) -- returns a pos by id. This is okay to do, but a very more
	-- efficient way of doing this is by indexing the position 
	table.remove(self.bodies, id);
end

local function collide(obj, world_block) -- if bounce is needed, it can be specified and used to reverse the obj's velocity
    local v, v2 = obj, world_block
    local dx = v2[1] - v.pos[1]
    local dy = v2[2] - v.pos[2]
    if dx<v.w and dx>-v2.w and dy<v.h and dy>-v2.h then
        local depthx = dx - v.w
        local depthy = dy - v.h
        local depth2x = -dx - v2.w
        local depth2y = -dy - v2.h
        local chx, chy = 0, 0;

        if math.abs(depthx) < math.abs(depth2x) then
            chx = -depthx;
        else
            chx = depth2x;
        end

        if math.abs(depthy) < math.abs(depth2y) then
            chy = -depthy;
        else
            chy = depth2y;
        end
        if math.abs(chx) < math.abs(chy) then
            chy = 0;
            v.vel[1] = 0; -- Collision on X, so vel.x becomes 0
        else
            chx = 0;
            v.vel[2] = 0; -- Collision ends on Y, so vel.y becomes 0
        end

        v.pos[1] = v.pos[1] - chx;
        v.pos[2] = v.pos[2] - chy;
        
    end
end

function bodies:update(dt)
    for k,v in pairs(self.bodies) do
        v.vel = v.vel + world.gravity*dt
        v.pos = v.pos + v.vel*dt
        for k2,v2 in pairs(world.blocks) do
            collide(v, v2)
        end
	end
end

return bodies;