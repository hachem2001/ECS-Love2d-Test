--local player = ECS:raw_new_entity("base") -- Inheritence is no more a thing now.
local player = {}

local jdelay = 0.1;
player.jump_delay = jdelay;
player.speed = 200;
function player:add(info) -- initializes the player
	-- since there is only one player, this really simply replaces the current player
	local w,h = info.w or 32, info.h or 32
	player.body_id, player.body = ECS:new_component("body", "player", 1, (info.x or 32)+w/2, (info.y or 32)+h/2, w, h, info.m, 
info.friction, info.bounciness)
end

function player:destroy(player_ind) -- removes a player, or in our case, the player
	ECS:queue_component_destroy("body", player.body_id);
end

--
--> Events
--

function player:draw()
	love.graphics.setColor(1,1,1,1)
	-- I could have used sdraw (smart draw) but the player is always displayed on the screen so yeah.
	love.graphics.rectangle("fill", self.body.pos.x-self.body.w/2, self.body.pos.y-self.body.h/2, self.body.w, self.body.h)
	camera:unset()
	love.graphics.print("Position : "..tostring(self.body.pos).."\nVelocity : "..tostring(self.body.vel), 50, 50);
	camera:set()
end

function player:is_on_ground()
	--This way is to make sure that if the player lands on a second player and the 2 are falling, or lands on land
	--then the player can still relatively jump 
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
		if self.body.vel.x < self.speed then
			self.body.vel.x = self.body.vel.x+self.speed*dt*3;
		end
	elseif love.keyboard.isDown("left") then
		if self.body.vel.x >-self.speed then
			self.body.vel.x = self.body.vel.x-self.speed*dt*3;
		end
	end

	if love.keyboard.isDown("up") and self:is_on_ground() and self.jump_delay<0 then
		self.body.vel.y = self.body.vel.y - ECS.components.body:to_pixels(9.1); -- Relative jump.
		self.jump_delay = jdelay;
	end
end

function player:mousepressed(x, y, button)
	--ECS:queue_entity_destroy("player", 1) -- any index really, because one player is used
	local wx, wy = camera:get_world_coordinates(x, y);

	local dir = vector(wx-self.body.pos.x, wy-self.body.pos.y)
	if button == 1 then	
		ECS:new_entity("bullets", {giver_body_id = self.body_id, name="player", id=1, pos=self.body.pos, direction=dir })
	elseif button == 2 then
		ECS:new_entity("world", {x=wx, y=wy, w=32 , h=32, friction=0.6, bounciness=0.1})
	end
end

return player;