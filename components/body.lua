--[[local ffi = require "ffi"
-- x y w and h are self explanatory. vx and vy are the velocity, m is the mass. f is the friction and b is the bounciness
--ffi.cdef("typedef struct {double x, y, vx, vy, w, h, m, f, b; } body_t;")
]]--

local bodies = {} -- or to be more precise : "rigidbody" like in Unity or such
bodies.bodies = {}; -- contains the bodies
bodies.boxes = {} -- used to divide the world into sections
bodies.debug = false;

bodies.meter = 32;

function bodies:to_meter(pixels)
    return pixels/self.meter;
end

function bodies:to_pixels(meters)
    return meters*self.meter;
end

bodies.gravity = vector(bodies:to_pixels(0), bodies:to_pixels(9.1));
bodies.air_volumetric_mass = 0.12

local BOX_DIV_W, BOX_DIV_H = 128, 128; -- divides the world by boxes
local min_box_w, min_box_h = 15, 15; -- Minimum box size
local num_on_div = 30; -- Number of entities on which a box would split on 4

local global_id = 1;

function bodies:add(entity_name, entity_id, x, y, w, h, m, friction, bounciness, adc) -- adds a rectangle (m is mass, friction is well, friction)

	-- if m == -1 the

	local mass = m or w*h

  local air_drag_coefficient = adc or 1

	local mm = {
			pos=vector(x, y),
			vel=vector(0,0),
			force=vector(0,0),
			w = w or 1, h = h or 1,
			px=0, py=0,

			m = mass,
			friction = friction or 1,
			air_drag_coefficient = air_drag_coefficient,
			bounciness = bounciness or 0,

			holder = {name = entity_name, id = entity_id}, -- the entity that is holding this
			last_collided_with = {}, -- contains the last_entites that were collided with : { {entitytype, id}, {enttype, id}, ...}
			-- if collision happened with the world, it would be {"world", block_id}

			gravity_effect = 1,
			static = mass < 0,
			categories_to_avoid = {}, -- Avoid collision with bodies whose holder name is of such category. "world" is used for the.
			ids_to_avoid = {}, -- Avoid collision with certain ids
			collide = true, -- can be set to false to make it not collide with anything
		}
	-- PX and PY contain the push on the X and Y axis respectively, after a collision happened
	self.bodies[global_id] = mm;
	global_id = global_id + 1;
	return global_id-1, mm;
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

local function small_coll(x1, y1, w1, h1, x2, y2, w2, h2) -- used just to know if collision happened
	local dx, dy = x2-w2/2-x1+w1/2, y2-h2/2-y1+h1/2;
	return dx<w1 and dx>-w2 and dy<h1 and dy>-h2;
end

local function coll_box_box(x1, y1, w1, h1, x2, y2, w2, h2) -- returns result, chx, chy ( chx and chy for how much to move the objects )
	local dx, dy = x2-w2/2-x1+w1/2, y2-h2/2-y1+h1/2;
	if not (dx<w1 and dx>-w2 and dy<h1 and dy>-h2) then
		return false
	else
		local depthx = dx - w1
		local depthy = dy - h1
		local depth2x = -dx - w2
		local depth2y = -dy - h2
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
		return true, chx, chy;
	end
end

local function collide_world(obj, world_block) -- if bounce is needed, it can be specified and used to reverse the obj's velocity
	local v, v2 = obj, world_block
	local result, chx, chy = coll_box_box(v.pos.x, v.pos.y, v.w, v.h, v2.pos.x, v2.pos.y, v2.w, v2.h)
	if result then
		local friction_line_vector; -- vector representing the plane on which friction occurs.
		if math.abs(chx) <= math.abs(chy) then
			chy = 0;
			v.px = v.px-chx -- Reverse this to indicate that a push on X on the opposite direction happened
			v.vel.y = v.vel.y * (1/(1+v.friction*v2.friction)); -- apply friction
			v.vel.x = -v.vel.x * (v.bounciness+v2.bounciness); -- Collision on X, so vel.x becomes 0
		else
			chx = 0;
			v.py = v.py-chy -- Reverse this to indicate that a push on Y on the opposite direction happened
			v.vel.y = -v.vel.y * (v.bounciness+v2.bounciness); -- Collision ends on Y, so vel.y becomes 0
			v.vel.x = v.vel.x * (1/(1+v.friction*v2.friction)); -- apply friction
		end

		v.pos.x = v.pos.x - chx;
		v.pos.y = v.pos.y - chy;

		return true;
	end
	return false;
end

local function collide_obj(obj1, obj2) -- With 2 colliding objects, the objects are pushed and the velocity vectors
	-- of the two are tweaked such that some part of each gets added to the other's
	local v, v2 = obj1, obj2
	local result, chx, chy = coll_box_box(v.pos.x, v.pos.y, v.w, v.h, v2.pos.x, v2.pos.y, v2.w, v2.h)
	if result then
		local friction_line_vector; -- vector representing the plane on which friction occurs.
		-- ^ this vector MUST BE normal. In case of a rotational world, the reason for this becomes even more obvious.
		local bounce_vector;
		if math.abs(chx) <= math.abs(chy) then
			chy = 0;
			friction_line_vector = vector(0,1);
			bounce_vector = vector(v2.vel.x-v.vel.x,0)*(v.bounciness+v2.bounciness);
		else
			chx = 0;
			friction_line_vector = vector(1,0);
			bounce_vector = vector(0,v2.vel.y-v.vel.y)*(v.bounciness+v2.bounciness);
		end
		local DIFF_VEC_VEL = v2.vel - v.vel -- Velocity difference vector
		local friction_vec_vel = friction_line_vector * (friction_line_vector*DIFF_VEC_VEL); -- Get the friction vector part of the difference vector
		local non_friction_vec_vel = DIFF_VEC_VEL - friction_vec_vel;
		local friction_product = v.friction * v2.friction -- Yes, I work with the product of the frictions of the two objects

		-- Precalculate some things :
		local Friction_add_vel = friction_vec_vel * (1- (1/(1+friction_product)));
		local sum = Friction_add_vel + non_friction_vec_vel + bounce_vector;
		-- Update the velocities
		local v2v = (v2.m/(v.m+v2.m));
		local vv2 = (v.m/(v2.m+v.m));
		v.vel = v.vel + v2v * sum;
		v2.vel = v2.vel - vv2 * sum;

		v.pos.x = v.pos.x - 2 * v2v * chx
		v.pos.y = v.pos.y - 2 * v2v * chy
		v2.pos.x = v2.pos.x + 2 * vv2 * chx
		v2.pos.y = v2.pos.y + 2 * vv2 * chy

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
function bodies:div_box(tbl, divw, divh, X, Y, dt)
	local ms = {}
	for kk,k in ipairs(tbl) do
		local v = self.bodies[k]
		local mx = math.abs(v.vel.x * dt);
		local my = math.abs(v.vel.y * dt);
		local first_box_X, first_box_Y = math.max(X/divw, math.floor((v.pos.x-v.w/2-mx)/divw)), math.max(Y/divh, math.floor((v.pos.y-v.h/2-my)/divh))
		local end_X, end_Y = math.min((X+divw)/divw, math.floor((v.pos.x+v.w/2+mx)/divw)), math.min((Y+divh)/divh, math.floor((v.pos.y+v.h/2+my)/divh))

		for MMX=first_box_X, end_X do
			for MMY=first_box_Y, end_Y do
				local MX, MY = MMX*divw,MMY*divh;
				if ms[MX] then
					if ms[MX][MY] then
						local index = #ms[MX][MY]+1
						ms[MX][MY][index] = k
					else
						ms[MX][MY] = {k,w=divw, h=divh};
					end
				else
					ms[MX] = {[MY] = {k,w=divw, h=divh}}
				end
			end
		end
	end
	self.boxes[X][Y] = {w=tbl.w, h=tbl.h};
	for XX,vv in pairs(ms) do
		for YY, v in pairs(vv) do
			if not self.boxes[XX] then
				self.boxes[XX] = {}
			end
			self.boxes[XX][YY] = v;
		end
	end
end

function bodies:update_boxes(dt) -- updates the layouts
	-- first, delete all boxes
	self.boxes = {}
	for k,v in pairs(self.bodies) do
		local mx = math.abs(v.vel.x) * dt;
		local my = math.abs(v.vel.y) * dt;
		local first_box_X, first_box_Y = math.floor((v.pos.x-v.w/2-mx)/BOX_DIV_W), math.floor((v.pos.y-v.h/2-my)/BOX_DIV_H)
		local end_X, end_Y = math.floor((v.pos.x+v.w/2+mx)/BOX_DIV_W), math.floor((v.pos.y+v.h/2+my)/BOX_DIV_H)

		for X=first_box_X, end_X do
			for MY=first_box_Y, end_Y do
				local MX, MY = X*BOX_DIV_W, MY*BOX_DIV_H;
				if self.boxes[MX] then
					if self.boxes[MX][MY] then
						local index = #self.boxes[MX][MY]+1
						self.boxes[MX][MY][index] = k
					else
						self.boxes[MX][MY] = {k,w=BOX_DIV_W, h=BOX_DIV_H};
					end
				else
					self.boxes[MX] = {[MY] = {k,w=BOX_DIV_W, h=BOX_DIV_H}}
				end
			end
		end
	end
	local to_del = {}
	for X, vv in pairs(self.boxes) do
		for Y, v in pairs(vv) do
			if #v> num_on_div and v.w/2>min_box_w and v.h/2>min_box_h then
				local prev_v = #v
				local m = self:div_box(v, v.w/2, v.h/2, X, Y, dt)
				if #self.boxes[X][Y] == 0 then
					to_del[#to_del+1] = {X, Y};
				end
			end
		end
	end
	for k, v in pairs(to_del) do
		self.boxes[v[1]][v[2]] = nil;
	end
end

function bodies:draw()
	if self.debug then
		for MX,vv in pairs(self.boxes) do
			for MY, v in pairs(vv) do
				if #v > 0 then
					love.graphics.setColor(1,1,1,1-(v.w/BOX_DIV_W)/2);
					love.graphics.rectangle('fill', MX+2, MY+2, v.w-2, v.h-2);
				end
			end
		end
	end
end

function bodies:pre_update(dt) -- physics update pre_update by default. Because entities might use the result just after
	self:update_boxes(dt) -- They are updated post this because some entities might be moving fast for example
	-- World collision MUST be BEFORE body woth body collision
	for k,v in pairs(self.bodies) do
		if not v.static then
			v.px = 0 -- Direction of X movement (before collision)
			v.py = 0 -- Direction of Y movement (before collision)

      -- Updating the position prematurely so the force and velocity the entities detect at the post update is simply the one they will move with next
      v.pos = v.pos + v.vel*dt;

			v.force = v.force + self.gravity*(v.m*v.gravity_effect); -- add gravity to the firce

			-- The drag force will have the opposite of the velocity vector, hence I did -v.vel^() so it takes the direction of -vel and the length of 0.5*...
      v.force = v.force - (#v.vel==0 and v.vel or v.vel^(0.5*self.air_volumetric_mass * (v.vel*v.vel) * v.air_drag_coefficient * v.w))

      v.vel = v.vel + (v.force/v.m)*dt; -- update velocity
			v.last_collided_with = {}; -- reinitialize the bodies collided with

			v.force = v.force*0;
		end
	end
	for X,vYs in pairs(self.boxes) do
		for Y, v in pairs(vYs) do
			if #v>1 then
				for k2 = #v, 1, -1 do
					local obj1 = self.bodies[v[k2]]
					if obj1.collide then
						for k3 = k2-1, 1, -1 do
							local obj2 = self.bodies[v[k3]]

							if obj2.collide then
								if not obj1.categories_to_avoid[obj2.holder.name] and not obj2.categories_to_avoid[obj1.holder.name] and not obj1.ids_to_avoid[k2] and not obj2.ids_to_avoid[k] then -- if the collision with the body k2 and k is not disabled by one of them
									local coll;
									if obj2.static and not obj1.static then -- 2 static objects don't need to collide
										coll = collide_world(obj1, obj2);
									elseif obj1.static and not obj2.static then
										coll = collide_world(obj2, obj1)
									elseif not obj1.static then -- and not obj2.static then
										coll = collide_obj(obj1, obj2)
									end
									if coll then
										obj1.last_collided_with[#obj1.last_collided_with+1] = {obj2.holder.name, obj2.holder.id};
										obj2.last_collided_with[#obj2.last_collided_with+1] = {obj1.holder.name, obj1.holder.id};
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

return bodies;
