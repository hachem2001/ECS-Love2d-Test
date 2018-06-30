local world = {}
local VV = {x=1,y=2,w=3,h=4,depth=5,[1]=1,[2]=2,[3]=3,[4]=4,[5]=5}
world.blocks = {}
world._blocks_mt = {
    __index = function(a, index)
        return rawget(a, VV[index]);
    end,
    __newindex = function(a, k, v)
        rawset(a, VV[k], v);
    end,
}

function world:to_meter(pixels)
    return pixels/self.meter
end

function world:to_pixels(meters)
    return meters*self.meter;
end

world.meter = 32 -- 32 pixels is how much considered a meter
world.gravity = vector:new(0, world:to_pixels(9.1));

local function sort_by_depth(a, b)
    return a[5] < b[5];
end

function world:add_block(x, y, w, h, friction, bounciness, depth)
    local index = #self.blocks+1
    self.blocks[index] = setmetatable({x, y, w, h, depth or index, friction or 1, bounciness or 0}, self._blocks_mt);
    table.sort(self, sort_by_depth);
    return index
end

function world:draw()
    love.graphics.setColor(0.7,0.8,0.5,1);
    for k = 1, #self.blocks do
        local v = self.blocks[k];
        love.graphics.rectangle("fill", v[1], v[2], v[3], v[4]);
    end
end

function world:update(dt)

end

return world;