local inputmanager = {}
-- What will happen in here is that some keys/scancodes/joystick inputs will be mapped into specific actions. So that if someone wants to check if the action "left"
-- has one corresponding keyboard being pressed, the input manager can return true.

-- The inputmanager also maps out some values like how much a gamepad stick is leaning on the left or the right ect. (Which are variable)

inputmanager.actions = {} -- For all actions, shows all keys connected
inputmanager.action_states = {} -- For efficiency, the quick result to actions are stored in here
inputmanager.scancodes = {} -- Reverse of actions, shows all scancodes connected to a certain action
inputmanager.keys = {} -- Reverse of actions, shows all actions connected
inputmanager.mouse_buttons = {} -- Reverse of actions, shows all actions connected
inputmanager.joysticks = {} -- joysticks can have variable inputs such as an axis's direction and how much is it pushed in that direction

--
-->Mappers
--

function inputmanager:map_scancodes(action, ...)
	local args = {...}
	for i, v in ipairs(args) do
		self:map_scancode(action, v)
	end
end

function inputmanager:map_keys(action, ...)
	local args = {...}
	for i, v in ipairs(args) do
		self:map_key(action, v)
	end
end

function inputmanager:map_scancode(action, key)
	if not self.actions[action] then
		self.actions[action] = {}
		self.action_states[action] = false;
	end
	if not self.scancodes[key] then
		self.scancodes[key] = {}
	end
	self.actions[action][#self.actions[action]+1] = {"s", key, love.keyboard.isScancodeDown(key)} -- First element is type of information, rest is info
	self.action_states[action] = self.action_states[action] or love.keyboard.isScancodeDown(key);
	-- since this is a scancode, the first element will be "s"
	self.scancodes[key][#self.scancodes[key]+1] = action;
end

function inputmanager:map_key(action, key)
	if not self.actions[action] then
		self.actions[action] = {}
		self.action_states[action] = false;
	end
	if not self.keys[key] then
		self.keys[key] = {}
	end
	self.actions[action][#self.actions[action]+1] = {"k", key, love.keyboard.isDown(key)} -- First element is type of information, rest is info
	self.action_states[action] = self.action_states[action] or love.keyboard.isDown(key);
	-- since this is a scancode, the first element will be "s"
	self.keys[key][#self.keys[key]+1] = action;
end

function inputmanager:map_mouse(action, mousebutton)
	if not self.actions[action] then
		self.actions[action] = {}
		self.action_states[action] = false;
	end
	if not self.mouse_buttons[mousebutton] then
		self.mouse_buttons[mousebutton] = {}
	end
	self.actions[action][#self.actions[action]+1] = {"m", mousebutton, love.mouse.isDown(mousebutton)} -- First element is type of information, rest is info
	self.action_states[action] = self.action_states[action] or love.mouse.isDown(mousebutton);
	-- since this is a scancode, the first element will be "s"
	self.mouse_buttons[mousebutton][#self.mouse_buttons[mousebutton]+1] = action;
end

function inputmanager:map_joystick_button(action, joystick_number, joystick_button )
	if not self.actions[action] then
		self.actions[action] = {}
		self.action_states[action] = false;
	end
	if not self.joysticks[joystick_number] then
		error("Please connect your joystick before you initialize the game.", 2);
	end
	if not self.joysticks[joystick_number].buttons[joystick_button] then
		self.joysticks[joystick_number].buttons[joystick_button] = {}
	end
	self.actions[action][#self.actions[action]+1] = {"j", joystick_number, self.joysticks[joystick_number]._joystick:isDown(joystick_button), joystick_button} -- First element is type of information, rest is info
	self.action_states[action] = self.action_states[action] or self.joysticks[joystick_number]._joystick:isDown(joystick_button);
	-- since this is a scancode, the first element will be "s"
	self.joysticks[joystick_number].buttons[joystick_button][#self.joysticks[joystick_number].buttons[joystick_button]+1] = action;
end

--
-->Demappers
--
-- For now no demappers, because I'm lazy to do them. They should remove a (key/mousebutton/joystickbutton/joystickaxis)/(action/value) pair, or demap e key (from all the actions it points to), or remove an action (and all the key references)
--
-->Getters
--

-- Third element in an action element is always the result.
function inputmanager:get_action(action) -- Returns true or false checking the key/mousebutton/joystickbutton corresponding
	return self.action_states[action];
end
--
-->To be used directly in main.lua
--

-- The following functions must be Used directly in main.lua in their corresponding functions, AND before anything else that uses the input manager
function inputmanager:keypressed(key, scancode, isrepeat)
	if self.keys[key] then
		local kactions = self.keys[key];
		for i,v in ipairs(kactions) do
			for k2,v2 in pairs(self.actions[v]) do
				if v2[1] == "k" and v2[2] == key then
					v2[3] = true;
					self.action_states[v] = true;
				end
			end
		end
	end
	if self.scancodes[scancode] then
		local sactions = self.scancodes[scancode]
		for i,v in ipairs(sactions) do
			for k2,v2 in pairs(self.actions[v]) do
				if v2[1] == "s" and v2[2] == scancode then
					v2[3] = true;
					self.action_states[v] = true;
				end
			end
		end
	end
end

function inputmanager:keyreleased(key, scancode, isrepeat)
	if self.keys[key] then
		local kactions = self.keys[key]
		for i,v in ipairs(kactions) do
			local result = false
			for k2,v2 in pairs(self.actions[v]) do
				if v2[1] == "k" and v2[2] == key then
					v2[3] = false;
				else
					result = result or v2[3];
				end
			end
			self.action_states[v] = result;
		end
	end
	if self.scancodes[scancode] then
		local sactions = self.scancodes[scancode]
		for i,v in ipairs(sactions) do
			local result = false
			for k2,v2 in pairs(self.actions[v]) do
				if v2[1] == "s" and v2[2] == scancode then
					v2[3] = false;
				else
					result = result or v2[3];
				end
			end
			self.action_states[v] = result;
		end
	end
end

function inputmanager:mousepressed(x, y, button, istouch)
	if self.mouse_buttons[button] then
		local kactions = self.mouse_buttons[button];
		for i,v in ipairs(kactions) do
			for k2,v2 in pairs(self.actions[v]) do
				if v2[1] == "m" and v2[2] == button then
					v2[3] = true;
					self.action_states[v] = true;
				end
			end
		end
	end
end

function inputmanager:mousereleased(x, y, button, istouch)
	if self.mouse_buttons[button] then
		local kactions = self.mouse_buttons[button]
		for i,v in ipairs(kactions) do
			local result = false
			for k2,v2 in pairs(self.actions[v]) do
				if v2[1] == "m" and v2[2] == button then
					v2[3] = false;
				else
					result = result or v2[3];
				end
			end
			self.action_states[v] = result;
		end
	end
end

function inputmanager:joystickadded(Joystick)
	self.joysticks[#self.joysticks+1] = {_joystick = Joystick, buttons={}};
end

function inputmanager:joystickremoved(Joystick)
	-- We can use Joystick:getID() to remove it from the joysticks list stored
	for k=#self.joysticks,1,-1 do
		local id = self.joysticks[k].__joystick:getID();
		if id == Joystick.getID() then
			table.remove(self.joysticks, k);
		end
	end

end

function inputmanager:joystickpressed(Joystick, button)
	local jk;
	for k,v in pairs(self.joysticks) do
		if v._joystick:getID() == Joystick:getID() then
			jk = k;
			break;
		end
	end
	if not jk then
		error("A joystick is connected but not detected by the inputmanager");
	end
	local jks = self.joysticks[jk];
	if jks.buttons[button] then
		local bactions = jks.buttons[button];
		for i,v in ipairs(bactions) do
			for k2,v2 in pairs(self.actions[v]) do
				if v2[1] == "j" and v2[2] == jk and v2[4] == button then
					v2[3] = true;
					self.action_states[v] = true;
				end
			end
		end
	end
end

function inputmanager:joystickreleased(Joystick, button)
	local jk;
	for k,v in pairs(self.joysticks) do
		if v._joystick:getID() == Joystick:getID() then
			jk = k;
			break;
		end
	end
	if not jk then
		error("A joystick is connected but not detected by the inputmanager");
	end
	local jks = self.joysticks[jk];
	if jks.buttons[button] then
		local bactions = jks.buttons[button];
		for i,v in ipairs(bactions) do
			local result = false;
			for k2,v2 in pairs(self.actions[v]) do
				if v2[1] == "j" and v2[2] == jk and v2[4] == button then
					v2[3] = false
				else
					result = result or v2[3];
				end
			end
			self.action_states[v] = result;
		end
	end
end

function inputmanager:joystickaxis(Joystick, axis, value)

end

function inputmanager:joystickhat(Joystick, hat, direction)

end

return inputmanager;
