-- NOTE : THE CAMERA MUST BE INITIALIZED AFTER :
-- GLOBAL (width) and (height) VARIABLES ARE SET UP IN THE LOVE.LOAD FUNCTION (CONTAINING THE CAMERA COORDINATES)
-- INCASE OF SCREEN SIZE RECHANGE, (camera.needs_update) NEEDS TO CHANGE TO TRUE.
local camera = {}

camera.w, camera.h = love.graphics.getDimensions();
camera.diagonal_squared = (camera.w^2 + camera.h^2)
camera.diagonal = camera.diagonal_squared^0.5

camera.x = 0;
camera.y = 0;
camera.scalex = 1;
camera.scaley = 1;
camera.shearx = 0;
camera.sheary = 0;
camera.angle = 0;
camera.ox, camera.oy = -width/2, -height/2;

camera.transform = love.math.newTransform(camera.x, camera.y, camera.angle,camera.scalex, camera.scaley, camera.ox, camera.oy, camera.shearx, camera.sheary);

camera.needs_update = false;

function camera:set()
	love.graphics.push();
	love.graphics.replaceTransform(self.transform);
end

function camera:unset()
	love.graphics.pop();
end

function camera:translate(dx, dy)
	camera.x, camera.y = camera.x - dx, camera.y - dy;
	camera.needs_update = true;
end

function camera:set_position(x, y)
	if not (camera.x == -x and camera.y == -y) then
		camera.x, camera.y = -x, -y;
		camera.needs_update = true;
	end
end

function camera:get_position()
	return camera.x, camera.y;
end

function camera:set_scale(sx, sy)
	if not (camera.scalex == sx and camera.scaley == sy) then
		camera.scalex = sx;
		camera.scaley = sy;
		camera.needs_update = true;
	end
end

function camera:get_scale()
	return camera.scalex, camera.scaley;
end

function camera:set_origin(x, y)
	if not (camera.ox == x and camera.oy == y) then
		camera.ox = x;
		camera.oy = y;
		camera.needs_update = true;
	end
end

function camera:get_origin()
	return camera.ox, camera.oy;
end

function camera:rotate(alpha)
	camera.angle = camera.angle + alpha;
	camera.needs_update = true;
end

function camera:set_rotation(alpha)
	camera.angle = alpha;
	camera.needs_update = true;
end

function camera:get_rotation()
	return camera.angle;
end

function camera:update(dt)
	-- Small fix commit
	if camera.needs_update then
		camera.transform = camera.transform:setTransformation(0, 0, camera.angle, 1, 1, camera.ox, camera.oy, camera.shearx, camera.sheary);
		camera.transform = camera.transform:scale(camera.scalex, camera.scaley):translate(camera.x, camera.y);
		camera.needs_update = false;
	end
end

function camera:get_world_coordinates(x, y)
	return self.transform:inverseTransformPoint(x, y)
end

function camera:get_screen_coordinates(x, y)
	return self.transform:transformPoint(x, y)
end

return camera;