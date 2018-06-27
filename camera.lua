-- NOTE : THE CAMERA MUST BE INITIALIZED AFTER :
-- GLOBAL (width) and (height) VARIABLES ARE SET UP IN THE LOVE.LOAD FUNCTION (CONTAINING THE CAMERA COORDINATES)
-- INCASE OF SCREEN SIZE RECHANGE, (camera.needs_update) NEEDS TO CHANGE TO TRUE.
local camera = {}
camera.x = 0;
camera.y = 0;
camera.scale = 1;
camera.shearx = 0;
camera.sheary = 0;
camera.angle = 0;
camera.ox, camera.oy = -width/2, -height/2;

camera.transform = love.math.newTransform(camera.x, camera.y, camera.angle,camera.scale, camera.scale,camera.ox, camera.oy, camera.shearx, camera.sheary);
camera.inv_transform = camera.transform:inverse();

camera.needs_update = false;

function camera:set()
	love.graphics.push();
	love.graphics.replaceTransform(self.transform);
end

function camera:unset()
	love.graphics.pop();
	--love.graphics.applyTransform(self.inv_transform);
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

function camera:set_origin(x, y)
	camera.ox = x;
	camera.oy = y;
	camera.needs_update = true;
	camera.needs_update = true;
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
		camera.transform = camera.transform:setTransformation(camera.x, camera.y, camera.angle, camera.scale, camera.scale, camera.ox, camera.oy, camera.shearx, camera.sheary);
		camera.inv_transform = camera.transform:inverse();
		camera.needs_update = false;
	end
end

return camera;