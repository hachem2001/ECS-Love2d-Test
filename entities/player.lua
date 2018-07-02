--local player = ECS:raw_new_entity("base") -- Inheritence is no more a thing now.
local player = {}

local jdelay = 0.1;
player.jump_delay = jdelay;
player.speed = 200;
function player:add(info) -- initializes the player
	-- since there is only one player, this really simply replaces the current player
	player.body_id, player.body = ECS:new_component("body", "player", 1, info.x or 32, info.y or 32, info.w or 32, info.h or 32, info.m, 
info.friction, info.bounciness)
end

function player:destroy(player_ind) -- removes a player, or in our case, the player
	--ECS:queue_component_destroy("position", player.position_id);--position no longer needed
	ECS:queue_component_destroy("body", player.body_id);
end

--
--> Events
--

function player:draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill", self.body.pos[1], self.body.pos[2], self.body.w, self.body.h)
	camera:unset()
	love.graphics.print("Position : "..tostring(self.body.pos).."\nVelocity : "..tostring(self.body.vel), 50, 50);
	camera:set()

	--camera:set_position(self.body.pos[1], self.body.pos[2]); -- moved to main - update(dt)
end

function player:is_on_ground()
	--return self.body.vel[2]==0 and self.body.py<0 and self.body.px == 0; --This old way of doing it 
	--is deprecated. The new one is to make sure that if the player lands on a second player and the 2 are falling,
	--then the player can still relatively jump from his land on him
	return self.body.py<0;
end


function player:update(dt) -- In the future, I might seperate the update function into a "post physics" update and a
	-- Pre physics update.
	self.jump_delay = self.jump_delay - dt;

	-- Handle collisions
	for k,v in pairs(self.body.last_collided_with) do
		-- Do stuff here
	end

	if love.keyboard.isDown("right") then
		if self.body.vel[1] < self.speed then
			self.body.vel[1] = self.body.vel[1]+self.speed*dt*3;
		end
	elseif love.keyboard.isDown("left") then
		if self.body.vel[1] >-self.speed then
			self.body.vel[1] = self.body.vel[1]-self.speed*dt*3;
		end
	end

	if love.keyboard.isDown("up") and self:is_on_ground() and self.jump_delay<0 then
		self.body.vel[2] = self.body.vel[2] - world:to_pixels(9.1); -- Relative jump.
		self.jump_delay = jdelay;
	end
end

function player:mousepressed(x, y, button)
	--ECS:queue_entity_destroy("player", 1) -- any index really, because one player is used
	local wx, wy = camera:get_world_coordinates(x, y);
	if button == 1 then	
		ECS:new_entity("bullets", {name="player", id=1, x=self.body.pos[1], y=self.body.pos[2], direction_x=self.body.pos[1]-wx, direction_y = self.body.pos[2]-wy, })
	elseif button == 2 then
		world:add_block(wx, wy, 32, 32, 7, 0);
	end
end

return player;