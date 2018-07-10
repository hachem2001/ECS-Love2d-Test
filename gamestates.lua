--
--> This is a manager for game states. Really useful
--

local gamestates = {};
gamestates.__gamestates_path = "gamestates/"
gamestates._toload = {
	playground = "playground.lua",
}

gamestates.gamestates = {}
gamestates.current_game_state = nil;
function gamestates:initialize(currgamestate)
	for k,v in pairs(self._toload) do
		self.gamestates[k] = love.filesystem.load(self.__gamestates_path..v)();
	end
	if not currgamestate then
		if self.gamestates[0] then
			self.current_game_state = 0;
		elseif self.gamestates["start"] then
			self.current_game_state = "start"
		else
			for k,v in pairs(self.gamestates) do
				self.current_game_state = k;
				break;
			end
		end
	else
		if self.gamestates[currgamestate] then
			self.current_game_state = currgamestate;
		else
			error("Gamestate "..currgamestate.." does not exist or is not loaded.", 2)
		end
	end
end

function gamestates:set_game_state(game_state_name, ...)
	if self.gamestates[game_state_name] then
		if self.gamestates[self.current_game_state].exit then
			self.gamestates[self.current_game_state]:exit()
		end
		self.current_game_state = game_state_name;
		if self.gamestates[self.current_game_state].switched_to then
			self.gamestates[self.current_game_state]:switched_to(...)
		end
	else
		error("Gamestate "..currgamestate.." does not exist or is not loaded.", 2)
	end
end

function gamestates:draw() -- All game states need a draw and an update function. I will not use if statements to tire this and make this run slower
	self.gamestates[self.current_game_state]:draw()
end

function gamestates:update(dt)
	self.gamestates[self.current_game_state]:update(dt)
end

function gamestates:keypressed(const, scancode, isrepeat)
	if self.gamestates[self.current_game_state].keypressed then
		self.gamestates[self.current_game_state]:keypressed(const, scancode, isrepeat)
	end
end

function gamestates:keyreleased(const, scancode, isrepeat)
	if self.gamestates[self.current_game_state].keyreleased then
		self.gamestates[self.current_game_state]:keyreleased(const, scancode, isrepeat)
	end
end

function gamestates:mousepressed(x, y, button, istouch)
	if self.gamestates[self.current_game_state].mousepressed then
		self.gamestates[self.current_game_state]:mousepressed(x, y, button, istouch)
	end
end

function gamestates:mousereleased(x, y, button, istouch)
	if self.gamestates[self.current_game_state].mousereleased then
		self.gamestates[self.current_game_state]:mousereleased(x, y, button, istouch)
	end
end

function gamestates:textinput( text )
	if self.gamestates[self.current_game_state].textinput then
		self.gamestates[self.current_game_state]:textinput( text )
	end
end

function gamestates:filedropped(file)
	if self.gamestates[self.current_game_state].filedropped then
		self.gamestates[self.current_game_state]:filedropped( file )
	end
end

function gamestates:focus(f)
	if self.gamestates[self.current_game_state].focus then
		self.gamestates[self.current_game_state]:focus( f )
	end
end

return gamestates;