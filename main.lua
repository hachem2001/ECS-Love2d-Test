--
--> Setup & Loading ----------------------------------------------------------------------------------------------------------------
--

math.randomseed(math.random(9999,99999)+os.time()*math.sin(os.time()))

__GAME_VERSION = "0.0.0.0"

function love.load()	
	width, height	= love.graphics.getDimensions()	-- Width and Height
	mousex,mousey	= love.mouse.getPosition()		-- Get the position of the mouse

	--> Get APIS
	colorutils	= require "apis/colorutils"				-- Color library, really useful.
	vector		= require "apis/vector"					-- Vector library needed

	--< End Get APIS
	--> Get SYSTEMS
	camera 		= require "camera"					-- The camera library
	sdraw		= require "smart_draw"
	ECS			= require "ECS"						-- Entity Component System
	world		= require "world"					-- World 
	--< End Get SYSTEMS


	--> Initialize SYSTEMS
	ECS:initialize();
	--< End Initialize SYSTEMS

	-- Add some blocks
	world:add_block(0, 16, 32, 32, 0.2, 0);
	world:add_block(32, 32, 32, 32, 0.2, 0);
	world:add_block(64, 32, 32, 32, 0.2, 0);
	world:add_block(96, 32, 1024, 32, 0.2, 0);
	world:add_block(1024, 16, 32, 32, 0.2, 0);

	-- Add a player

	ECS:new_entity("player", {x=32, y=0, w=32, h=32, friction=0.2, bounciness=0.1})
	ECS:new_entity("npcs", {x=64, y=-200, w=16, h=16, friction=0.2, bounciness=0.1})
	ECS:new_entity("npcs", {x=80, y=-200, w=16, h=16, friction=0.2, bounciness=0.1})
	ECS:new_entity("npcs", {x=96, y=-200, w=16, h=16, friction=0.2, bounciness=0.1})

	-- Testing
	-- local v = vector(1,2)^1;
	-- local v2 = vector(1, 1);
	-- local v3 = v*(v*v2)
	-- print(v*v2);
	-- print(v, v2, v3);
	-- print(vector.getlength(v3));
	--camera:set_scale(0.5,0.5)
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
	ECS:update(dt);

	camera:set_position(ECS.entities["player"].body.body.p.x, ECS.entities["player"].body.body.p.y)
	camera:update(dt);
end

function love.keypressed(const, scancode, isrepeat)
	ECS:keypressed(const, scancode, isrepeat);
end

function love.keyreleased(const, scancode, isrepeat)
	ECS:keyreleased(const, scancode, isrepeat);
end

function love.mousepressed(x, y, button, istouch)
	ECS:mousepressed(x,y,button, istouch)
end

function love.mousereleased(x, y, button, istouch)
	ECS:mousereleased(x,y,button, istouch)
end

function love.textinput( text )

end

function love.filedropped(file)

end

function love.focus(f)

end