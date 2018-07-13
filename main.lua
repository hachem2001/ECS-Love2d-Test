--
--> Setup & Loading ----------------------------------------------------------------------------------------------------------------
--

math.randomseed(math.random(9999,99999)+os.time()*math.sin(os.time()))

__GAME_VERSION = "0.0.0.0"

function love.load()	
	width, height	= love.graphics.getDimensions()	-- Width and Height
	mousex,mousey	= love.mouse.getPosition()		-- Get the position of the mouse

	--> Get APIS
	colorutils	= require "apis/colorutils"			-- Color library, really useful.
	vector		= require "apis/vector"				-- Vector library needed
	--< End Get APIS
	--> Get SYSTEMS
	camera 		= require "camera"					-- The camera library
	inputmanager= require "inputmanager"			-- Inputmanager that makes handling keyboard mouse and joystick inputs a little easier. Still didn't make the mouse and joystick part though
	sdraw		= require "smart_draw"				-- Was gonna use it to limit my draw calls, didn't update it yet
	ECS			= require "ECS"						-- Entity Component System
	--< End Get SYSTEMS
	gamestates	= require "gamestates"				-- Handles game states.

	print(love.graphics.getRendererInfo())
	--> Initialize SYSTEMS
	ECS:initialize();
	gamestates:initialize();
	--< End Initialize SYSTEMS


	-- Add a player
	ECS:new_entity("player", {x=296, y=0, w=32, h=32, friction=0.2, bounciness=0.9})
	-- Add NPCS
	ECS:new_entity("npcs", {x=32, y=-128, w=31, h=31, friction=0.2, bounciness=0.1})
	ECS:new_entity("npcs", {x=32, y=-64, w=31, h=31, friction=0.2, bounciness=0.1})
	ECS:new_entity("npcs", {x=32, y=0, w=31 , h=31, friction=0.2, bounciness=0.1})
	-- Add some blocks
	ECS:new_entity("world", {x=32, y=32, w=1024 , h=32, friction=0.2, bounciness=0})
	camera:set_scale(1,1)

	inputmanager:map_scancodes("left", "a", "left");
	inputmanager:map_keys("right", "d", "right");
	inputmanager:map_scancodes("up", "w", "up");

	_DELAY_T = 0;
	_DELAY_TT = 5;
end

--
--> Game events --------------------------------------------------------------------------------------------------------------------
--

function love.draw()
	gamestates:draw();
end

function love.update(dt)
	gamestates:update(dt);
end

function love.keypressed(const, scancode, isrepeat)
	inputmanager:keypressed(const, scancode, isrepeat);
	gamestates:keypressed(const, scancode, isrepeat);
end

function love.keyreleased(const, scancode, isrepeat)
	inputmanager:keyreleased(const, scancode, isrepeat);
	gamestates:keyreleased(const, scancode, isrepeat);
end
 
function love.mousepressed(x, y, button, istouch)
	inputmanager:mousepressed(x, y, button, istouch);
	gamestates:mousepressed(x,y,button, istouch);
end 

function love.mousereleased(x, y, button, istouch)
	inputmanager:mousereleased(x, y, button, istouch)
	gamestates:mousereleased(x,y,button, istouch);
end

function love.textinput( text )
	gamestates:textinput( text );
end

function love.filedropped(file)
	gamestates:filedropped(file);
end

function love.focus(f)
	gamestates:focus(f);
end--]]--
