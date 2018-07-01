local bodies = {} -- or to be more precise : "rigidbody" like in Unity or such
bodies.bodies = {};

local materials = {plastic = 1, gold = 2.8, iron=7.3} -- Perhaps I'll use this at a later stage

function bodies:add(x, y, w, h, m, friction, bounciness) -- adds a rectangle (m is mass, friction is well, friction)
	local m = {pos=vector:new(x, y),
			w = w or 1, h = h or 1,
			vel=vector:new(0,0),
			px=0, py=0,
			m = m or w*h,
			friction = friction or 1,
			bounciness = bounciness or 0,
		}
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

		if math.abs(depthx) <= math.abs(depth2x) then
			chx = -depthx;
		else
			chx = depth2x;
		end

		if math.abs(depthy) <= math.abs(depth2y) then
			chy = -depthy;
		else
			chy = depth2y;
		end

		local friction_line_vector; -- vector representing the plane on which friction occurs.
		if math.abs(chx) <= math.abs(chy) then
			chy = 0;
			v.px = v.px-chx -- Reverse this to indicate that a push on X on the opposite direction happened
			v.vel[2] = v.vel[2] * (1/(1+v.friction*v2[6])); -- apply friction
			v.vel[1] = -v.vel[1] * (v.bounciness+v2[7]); -- Collision on X, so vel.x becomes 0
		else
			chx = 0;
			v.py = v.py-chy -- Reverse this to indicate that a push on Y on the opposite direction happened
			v.vel[2] = -v.vel[2] * (v.bounciness+v2[7]); -- Collision ends on Y, so vel.y becomes 0
			v.vel[1] = v.vel[1] * (1/(1+v.friction*v2[6])); -- apply friction
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

		if math.abs(depthx) <= math.abs(depth2x) then
			chx = -depthx;
		else
			chx = depth2x;
		end

		if math.abs(depthy) <= math.abs(depth2y) then
			chy = -depthy;
		else
			chy = depth2y;
		end
		
		local friction_line_vector; -- vector representing the plane on which friction occurs.
		-- ^ this vector MUST BE normal. In case of a rotational world, the reason for this becomes even more obvious.
		local bounce_vector;
		if math.abs(chx) <= math.abs(chy) then
			chy = 0;
			friction_line_vector = vector:new(0,1);
			bounce_vector = vector:new(v2.vel[1]-v.vel[1],0)*(v.bounciness+v2.bounciness);
		else
			chx = 0;
			friction_line_vector = vector:new(1,0);
			bounce_vector = vector:new(0,v2.vel[2]-v.vel[2])*(v.bounciness+v2.bounciness);
		end
		local DIFF_VEC_VEL = v2.vel - v.vel -- Velocity difference vector
		local friction_vec_vel = friction_line_vector * (friction_line_vector*DIFF_VEC_VEL); -- Get the friction vector part of the difference vector
		local non_friction_vec_vel = DIFF_VEC_VEL - friction_vec_vel;
		local friction_product = v.friction * v2.friction -- Yes, I work with the product of the frictions of the two objects
		
		-- Precalculate some things :
		local Friction_add_vel = friction_vec_vel * (1- (1/(1+friction_product)));
		local sum = Friction_add_vel + non_friction_vec_vel + bounce_vector;
		-- Update the velocities
		print(bounce_vector, sum);
		v.vel = v.vel + (v2.m/(v.m+v2.m)) * sum;
		v2.vel = v2.vel - (v.m/(v2.m+v.m)) * sum;

		v.pos[1] = v.pos[1] - chx --- v2.px;
		v.pos[2] = v.pos[2] - chy --- v2.py;
		v2.pos[1] = v2.pos[1] + chx --+ v.px;
		v2.pos[2] = v2.pos[2] + chy --+ v.py;

		if chx == 0 then
			v.py = v.py-chy -- Reverse this to indicate that a push on Y on the opposite direction happened
			v2.py = v2.py+chy -- Reverse this to indicate that a push on Y on the opposite direction happened
		else
			v.px = v.px-chx; -- Reverse this to indicate that a push on X on the opposite direction happened
			v2.px = v2.px+chx; -- Same for the other object
		end
	end
end

function bodies:update(dt)
	-- World collision MUST be BEFORE body woth body collision
	for k=#self.bodies, 1, -1 do
		local v = self.bodies[k]
		v.px = 0 -- Direction of X movement (before collision)
		v.py = 0 -- Direction of Y movement (before collision)
		v.vel = v.vel + world.gravity*dt
		v.pos = v.pos + v.vel*dt
		for k2,v2 in pairs(world.blocks) do
			collide_world(v, v2)
		end
	end
	for k=#self.bodies, 1, -1 do
		local v = self.bodies[k]
		for k2 = k-1, 1, -1 do
			local v2 = self.bodies[k2]
			collide_obj(v, v2)
		end
	end
end

return bodies;