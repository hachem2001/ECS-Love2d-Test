local smart_draw = {} -- This utility REQUIRES camera.
-- It is used in order to ignore drawing entites/rectangles/anything that is far from screen.

local lg = love.graphics
function smart_draw.rectangle(mode, x, y, w, h)
    if true or ((camera.x - x)^2 + (camera.y - y)^2)^0.5 <camera.diagonal+w+h then
        lg.rectangle(mode, x, y, w, h);
    end
end

return smart_draw;