--[[
	The big changes :
	• entities are divided into batches. The player is his own batch with 1 single plaer,
	but many other players
	• components are also divided in batches. Positions are run in one file, same goes for rigid bodies
	etc
]]
local ECS = {}
ECS._entities_path	  = "entities/"
ECS._components_path	= "components/"

ECS._entity_names = {
	world = "world.lua",
	player = "player.lua",
	npcs = "npcs.lua",
	bullets = "bullets.lua",
	pushpellets = "pushpellets.lua",
}

ECS._component_names = {
	position = "position.lua",
	body = "body.lua"
}

ECS.components = {}
ECS.entities   = {}

ECS.entities_to_destroy	 = {}
ECS.components_to_destroy   = {}

ECS.components_draw_order = {}
ECS.entities_draw_order = {}

-- The components table stores components as classified by tables.
-- As such, each batch of components of the same type are updated together in the same script which is
-- The script that is used to load them

function ECS:initialize()
	-- COMPONENTS MUST BE INITIALIZED BEFORE ENTITIES. BECAUSE SOME ENTITIES WILL CREATE THEM JUST AS LOADED
	print("Loading components :")
	for k,v in pairs(self._component_names) do
		print("\tLoaded : "..k.." "..v);
		self.components[k] = love.filesystem.load(self._components_path..v)()
		if self.components[k].draw then
			self.components_draw_order[#self.components_draw_order+1] = k
			self.components[k].__draw_order = self.components[k].__draw_order or 9999
		end
	end

	print("Loading entities :")
	for k,v in pairs(self._entity_names) do
		print("\tLoaded : "..k.." "..v);
		self.entities[k] = love.filesystem.load(self._entities_path..v)()
		if self.entities[k].draw then
			self.entities_draw_order[#self.entities_draw_order+1] = k
			self.entities[k].__draw_order = self.entities[k].__draw_order or 9999
		end
	end

	table.sort(self.components_draw_order, function(a, b) return self.components[a].__draw_order < self.components[b].__draw_order end)
	table.sort(self.entities_draw_order, function(a, b) return self.entities[a].__draw_order < self.entities[b].__draw_order end)
end

local function sort_by_layer(a, b)
	return a.layer < b.layer
end
--
-- REMARK : ENTITY WORKS IS SUPPLIED WITH AN INFO TABLE
-- COMPONENTS ARE SUPPLIED THE ... WAY.
--
function ECS:new_entity(type, info) 
	-- Due to the change on how entities work, there is really no direct way to set up
	-- which entity to draw before the other
	-- Should basically return 
	return self.entities[type]:add(info);
end

function ECS:new_component(type, ...) -- returns the ID of the component as well as any other extra information (ex : reference of the table of the component), this information must be stored by the entity so that it can 
	-- use it (ex : positions or such) and so that the entity class destroy it once it destroys an entity
	return self.components[type]:add(...);
end

function ECS:queue_entity_destroy(type, id) -- This can be called from a component such as health to indicate that entity has no more health
	for i,v in ipairs(self.entities_to_destroy) do
		if v[1] == type and v[2] == id then
			return; -- if already pushed to be deleted, why delete it twice? Just return
		end
	end
	self.entities_to_destroy[#self.entities_to_destroy+1] = {type=type, id=id}
end

function ECS:queue_component_destroy(type, id) -- This is called to destroy a component
	for i,v in ipairs(self.components_to_destroy) do
		if v[1] == type and v[2] == id then
			return; -- if already pushed to be deleted, why delete it twice? Just return
		end
	end
	self.components_to_destroy[#self.components_to_destroy+1] = {type=type, id=id}
end

--
--> Events
--

function ECS:draw()
	for i,v in ipairs(self.components_draw_order) do
		self.components[v]:draw()
	end
	for i,v in ipairs(self.entities_draw_order) do
		self.entities[v]:draw()
	end
end

function ECS:pre_update(dt)
	for k,v in pairs(self.components) do
		if v.pre_update then
			v:pre_update(dt)
		end
	end
	for k,v in pairs(self.entities) do
		if v.pre_update then
			v:pre_update(dt)
		end
	end
	
	for k=#self.entities_to_destroy, 1, -1 do
		local v = self.entities_to_destroy[k];
		self.entities[v.type]:destroy(v.id);
		table.remove(self.entities_to_destroy, k);
	end
	for k=#self.components_to_destroy, 1, -1 do
		local v = self.components_to_destroy[k];
		self.components[v.type]:destroy(v.id);
		table.remove(self.components_to_destroy, k);
	end
	
end

function ECS:update(dt)
	-- Do pre_update
	self:pre_update(dt);
	-- then do update
	for k,v in pairs(self.components) do
		if v.update then
			v:update(dt)
		end
	end
	for k,v in pairs(self.entities) do
		if v.update then
			v:update(dt)
		end
	end
	-- entities are destroyed at pre_update
end

function ECS:keypressed(const, scancode, isrepeat)
	for k,v in pairs(self.components) do
		if v.keypressed then
			v:keypressed(const, scancode, isrepeat)
		end
	end
	for k,v in pairs(self.entities) do
		if v.keypressed then
			v:keypressed(const, scancode, isrepeat)
		end
	end
end

function ECS:keyreleased(const, scancode, isrepeat)
	for k,v in pairs(self.components) do
		if v.keyreleased then
			v:keyreleased(const, scancode, isrepeat)
		end
	end
	for k,v in pairs(self.entities) do
		if v.keyreleased then
			v:keyreleased(const, scancode, isrepeat)
		end
	end
end

function ECS:mousepressed(x, y, button, istouch)
	for k,v in pairs(self.components) do
		if v.mousepressed then
			v:mousepressed(x, y, button, istouch)
		end
	end
	for k,v in pairs(self.entities) do
		if v.mousepressed then
			v:mousepressed(x, y, button, istouch)
		end
	end
end

function ECS:mousereleased(x, y, button, istouch)
	for k,v in pairs(self.components) do
		if v.mousereleased then
			v:mousereleased(x, y, button, istouch)
		end
	end
	for k,v in pairs(self.entities) do
		if v.mousereleased then
			v:mousereleased(x, y, button, istouch)
		end
	end
end

return ECS