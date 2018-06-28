--local player = ECS:raw_new_entity("base") -- Inheritence is no more a thing now.
local player = {}

player.position_id, player.position = ECS:new_component("position", 32, 32);
player.body_id, player.body = ECS:new_component("body", 32, 32, 32, 32);

function player:add(info) -- initializes the player
	-- since there is only one player, this really simply replaces the current player
	self.body.pos[1], self.body.pos[2], self.body.w, self.body.h = info.x or self.body[1] ,info.y or self.body[2],info.w or self.body[3], info.h or self.body[4];
end

function player:destroy(player_ind) -- removes a player, or in our case, the player
	ECS:queue_component_destroy("position", player.position_id);
	ECS:queue_component_destroy("body", player.body_id);
end

--
--> Events
--

function player:draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill", self.body.pos[1], self.body.pos[2], self.body.w, self.body.h)

	camera:set_position(self.body.pos[1], self.body.pos[2]);
end

function player:is_on_ground()
	return self.body.vel[2]==0 and self.body.py<0;
end

function player:update(dt)
	if love.keyboard.isDown("right") then
		self.body.vel[1] = 100;
	elseif love.keyboard.isDown("left") then
		self.body.vel[1] = -100;
	else
		self.body.vel[1] = 0;
	end

	if love.keyboard.isDown("up") and self:is_on_ground() then
		self.body.vel[2] = -100;
	end
end

function player:mousepressed(x, y, button)
	--ECS:queue_entity_destroy("player", 1) -- any index really, because one player is used
end


return player