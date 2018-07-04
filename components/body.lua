local bodies = {} -- or to be more precise : "rigidbody" like in Unity or such
bodies.bodies = {};

local materials = {plastic = 1, gold = 2.8, iron=7.3} -- Perhaps I'll use this at a later stage
local global_id = 1

function bodies:add(entity_name, entity_id, x, y, w, h, m, friction, bounciness) -- adds a rectangle (m is mass, friction is well, friction)
	local m = {pos=vector:new(x, y),
			w = w or 1, h = h or 1,
			vel=vector:new(0,0),
			px=0, py=0,
			m = m or w*h,
			friction = friction or 1,
			bounciness = bounciness or 0,
			holder = {name = entity_name, id = entity_id}, -- the entity that is holding this
			last_collided_with = {}, -- contains the last_entites that were collided with : { {entitytype, id}, {enttype, id}, ...}
			-- if collision happened with the world, it would be {"world", block_id}
			gravity_effect = 1,
			categories_to_avoid = {}, -- Avoid collision with bodies whose holder name is of such category. "world" is used for the.
			ids_to_avoid = {}, -- Avoid collision with certain ids
			collide_with_entities = true, -- can be set to false to make it only collide with the world
		}
	-- PX and PY contain the push on the X and Y axis respectively, after a collision happened
	self.bodies[global_id] = m;
	global_id = global_id + 1;
	return global_id-1, m;
end

function bodies:avoid_category(id, category_to_avoid)
	-- id : id of the body
	-- category_to_avoid : entity type / holder name for the body to avoid
	self.bodies[id].categories_to_avoid[category_to_avoid] = true
end

function bodies:avoid_id(id, id2)
	-- id : id of the body
	-- id2 : id of the body to avoid
	self.bodies[id].ids_to_avoid[id2] = true
end

function bodies:destroy(id) -- returns a pos by id. This is okay to do, but a very more
	-- efficient way of doing this is by indexing the position
	self.bodies[id] = nil;
end

local function collide_world(obj, world_block) -- if bounce is needed, it can be specified and used to reverse the obj's velocity
	local v, v2 = obj, world_block
	local dx = v2[1]-v2[3]/2 - v.pos[1] + v.w/2
	local dy = v2[2]-v2[4]/2 - v.pos[2] + v.h/2
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

		return true;
	end
	return false;
end

local function collide_obj(obj1, obj2) -- With 2 colliding objects, the objects are pushed and the velocity vectors
	-- of the two are tweaked such that some part of each gets added to the other's
	local v, v2 = obj1, obj2
	local dx = v2.pos[1]-v2.w/2 - v.pos[1]+v.w/2;
	local dy = v2.pos[2]-v2.h/2 - v.pos[2]+v.h/2;
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
		v.vel = v.vel + (v2.m/(v.m+v2.m)) * sum;
		v2.vel = v2.vel - (v.m/(v2.m+v.m)) * sum;

		v.pos[1] = v.pos[1] - chx
		v.pos[2] = v.pos[2] - chy
		v2.pos[1] = v2.pos[1] + chx
		v2.pos[2] = v2.pos[2] + chy

		if chx == 0 then
			v.py = v.py-chy -- Reverse this to indicate that a push on Y on the opposite direction happened
			v2.py = v2.py+chy -- Reverse this to indicate that a push on Y on the opposite direction happened
		else
			v.px = v.px-chx; -- Reverse this to indicate that a push on X on the opposite direction happened
			v2.px = v2.px+chx; -- Same for the other object
		end

		return true;
	end
	return false
end

function bodies:update(dt)
	-- World collision MUST be BEFORE body woth body collision
	for k=global_id-1, 1, -1 do
		local v = self.bodies[k]
		if v then
			v.px = 0 -- Direction of X movement (before collision)
			v.py = 0 -- Direction of Y movement (before collision)
			v.vel = v.vel + world.gravity*v.gravity_effect*dt
			v.pos = v.pos + v.vel*dt
			v.last_collided_with = {};
			if not v.categories_to_avoid["world"] then -- If the collision with the world is not disabled
				for k2,v2 in pairs(world.blocks) do
					local coll = collide_world(v, v2)
					if coll then
						v.last_collided_with[#v.last_collided_with+1] = {"world", k2};
					end
				end
			end
		end
	end
	for k=global_id-1, 1, -1 do
		local v = self.bodies[k]
		if v and v.collide_with_entities then
			for k2 = k-1, 1, -1 do
				local v2 = self.bodies[k2]
				if v2 and not v.ids_to_avoid[k2] and not v2.ids_to_avoid[k] and not v.categories_to_avoid[v2.holder.name] and not v2.categories_to_avoid[v.holder.name] then -- if the collision with the body k2 and k is not disabled by one of them
					local coll = collide_obj(v, v2)
					if coll then
						v.last_collided_with[#v.last_collided_with+1] = {v2.holder.name, v2.holder.id};
						v2.last_collided_with[#v2.last_collided_with+1] = {v.holder.name, v.holder.id};
					end
				end
			end
		end
	end
end

return bodies;