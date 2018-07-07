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
	--< End Get SYSTEMS


	--> Initialize SYSTEMS
	ECS:initialize();
	--< End Initialize SYSTEMS


	-- Add a player
	ECS:new_entity("player", {x=296, y=0, w=32, h=32, friction=0.2, bounciness=0.1})
	-- Add NPCS
	-- ECS:new_entity("npcs", {x=32, y=-128, w=31, h=31, friction=0.2, bounciness=0.1})
	-- ECS:new_entity("npcs", {x=32, y=-64, w=31, h=31, friction=0.2, bounciness=0.1})
	-- ECS:new_entity("npcs", {x=32, y=0, w=31 , h=31, friction=0.2, bounciness=0.1})
	-- Add some blocks
	ECS:new_entity("world", {x=32, y=32, w=1024 , h=32, friction=0.2, bounciness=0.1})


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
	ECS:draw()
	camera:unset()
end

function love.update(dt)
	mousex,mousey	= love.mouse.getPosition()				-- Update the position of the mouse ( in any circumstances )
	ECS:update(dt);

	camera:set_position(ECS.entities["player"].body.pos.x, ECS.entities["player"].body.pos.y)
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

end--]]--
