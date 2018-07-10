local playground = {}

function playground:switched_to(...) -- If the gamestate is being switched from one gamestate to this current one. Info can be given through this.

end

function playground:draw()
	love.window.setTitle(love.timer.getFPS());

	camera:set()
	ECS:draw()
	camera:unset()
end

function playground:update(dt)
	if dt < 200/1000 then --shouldn't update when game is too slow
		mousex,mousey	= love.mouse.getPosition()				-- Update the position of the mouse ( in any circumstances )
		ECS:update(dt);

		camera:set_position(ECS.entities["player"].body.pos.x, ECS.entities["player"].body.pos.y)
		camera:update(dt);

		_DELAY_T = _DELAY_T - dt;
		if _DELAY_T < 0 then
			--print("Current memory usage "..(collectgarbage("count")))
			_DELAY_T = _DELAY_TT;
		end
	end
end

function playground:keypressed(key, scancode, isrepeat)
	ECS:keypressed(const, scancode, isrepeat);
end

function playground:keyreleased(key, scancode, isrepeat)
	ECS:keyreleased(const, scancode, isrepeat);
end

function playground:mousepressed(x, y, button, istouch)
	ECS:mousepressed(x,y,button, istouch)
end

function playground:mousereleased(x, y, button, istouch)
	ECS:mousereleased(x,y,button, istouch)
end

function playground:textinput( text )

end

function playground:filedropped(file)

end

function playground:focus(f)

end

function playground:exit() -- This is when the gamestates manager will switch from one state to another.
    ECS:initialize(true) -- reloads the ECS system.
end

return playground;