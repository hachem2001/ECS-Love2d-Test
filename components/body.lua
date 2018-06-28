local bodies = {} -- or to be more precise : "rigidbody" like in Unity or such
bodies.bodies = {};

function bodies:add(x, y, w, h, m) -- adds a rectangle (m is mass)
    local m = {pos=vector:new(x, y), w = w or 1, h = h or 1, vel=vector:new(0,0), px=0, py=0, m = m or w*h}
    -- PX and PY contain the push on the X and Y axis respectively, after a collision happened
	local index = #self.bodies+1;
	self.bodies[index] = m;
	return index, m;
end

function bodies:destroy(id) -- returns a pos by id. This is okay to do, but a very more
	-- efficient way of doing this is by indexing the position 
	table.remove(self.bodies, id);
end

local function collide_world(obj, world_block) -- if bounce is needed, it can be specified and used to reverse the obj's velocity
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
        if math.abs(chx) <= math.abs(chy) then
            chy = 0;
            v.px = -chx -- Reverse this to indicate that a push on X on the opposite direction happened
            v.vel[1] = 0; -- Collision on X, so vel.x becomes 0
        else
            chx = 0;
            v.py = -chy -- Reverse this to indicate that a push on Y on the opposite direction happened
            if v.py*world.gravity[2] <0 then
                v.vel[2] = 0; -- Collision ends on Y, so vel.y becomes 0
            end
        end

        v.pos[1] = v.pos[1] - chx;
        v.pos[2] = v.pos[2] - chy;
        
    end
end

local function collide_obj(obj1, obj2) -- With 2 colliding objects, the objects are pushed and the velocity vectors
    -- of the two are tweaked such that some part of each gets added to the other's
    local v, v2 = obj1, obj2
    local dx = v2.pos[1] - v.pos[1]
    local dy = v2.pos[2] - v.pos[2]
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

        if math.abs(chx) <= math.abs(chy) then
            chy = 0;
            v.px = -chx; -- Reverse this to indicate that a push on X on the opposite direction happened
            v2.px = chx; -- Same for the other object
            v.vel[1] = 0; -- Collision on X, so vel.x becomes 0
            v2.vel[1] = 0; -- Collision on X, so vel.x becomes 0
        else
            chx = 0;
            v.py = -chy -- Reverse this to indicate that a push on Y on the opposite direction happened
            v2.py = chy -- Reverse this to indicate that a push on Y on the opposite direction happened
            if v.py*world.gravity[2] <0 then
                v.vel[2] = 0; -- Collision ends on Y, so vel.y becomes 0
            end
        end

        v.pos[1] = v.pos[1] - chx/2;
        v.pos[2] = v.pos[2] - chy/2;
        v2.pos[1] = v2.pos[1] + chx/2;
        v2.pos[2] = v2.pos[2] + chy/2;
        
    end
end

function bodies:update(dt)
    for k=#self.bodies, 1, -1 do
        local v = self.bodies[k]
        v.vel = v.vel + world.gravity*dt
        v.pos = v.pos + v.vel*dt
        v.px = 0 -- Direction of X movement (before collision)
        v.py = 0 -- Direction of Y movement (before collision)
        for k2,v2 in pairs(world.blocks) do
            collide(v, v2)
        end
        for k2 = k-1, 1, -1 do
            local v2 = self.bodies[k2]
            collide_obj(v, v2)
        end
    end

end

return bodies;