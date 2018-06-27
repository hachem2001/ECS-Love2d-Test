--
--> Setup & Loading ----------------------------------------------------------------------------------------------------------------
--

math.randomseed(math.random(9999,99999)+os.time()*math.sin(os.time()))

__GAME_VERSION = "0.0.0.0"

function love.load()	
	width, height	= love.graphics.getDimensions()	-- Width and Height
	mousex,mousey	= love.mouse.getPosition()		-- Get the position of the mouse

	--> Get APIS
	vector		= require "apis/vector"					-- Vector library needed
	--< End Get APIS
	
	--> Get SYSTEMS
	camera 		= require "camera"					-- The camera library
	ECS			= require "ECS"						-- Entity Component System
	world		= require "world"					-- World 
	--< End Get SYSTEMS


	--> Initialize SYSTEMS
	ECS:initialize();
	--< End Initialize SYSTEMS

	-- Add some blocks
	world:add_block(32, 32, 32, 32);
	world:add_block(64, 32, 32, 32);
	world:add_block(96, 32, 32, 32);
	-- Add a player
	ECS:new_entity("player", {x=32, y=0, w=32, h=32})
end

--
--> Game events --------------------------------------------------------------------------------------------------------------------
--

function love.draw()
	love.window.setTitle(love.timer.getFPS());

	camera:set()
	world:draw();
	ECS:draw()
	camera:unset()
end

function love.update(dt)
	mousex,mousey	= love.mouse.getPosition()				-- Update the position of the mouse ( in any circumstances )
	camera:update(dt)
	ECS:update(dt);
end

function love.keypressed(const, scancode, isrepeat)

end

function love.keyreleased(const, scancode, isrepeat)

end

function love.mousepressed(x, y, button, istouch)
	ECS:mousepressed(x,y,button, istouch)
end

function love.mousereleased(x, y, button, istouch)

end

function love.textinput( text )

end

function love.filedropped(file)

end

function love.focus(f)

end