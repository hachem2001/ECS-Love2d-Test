local world = {}
local VV = {x=1,y=2,w=3,h=4,depth=5,[1]=1,[2]=2,[3]=3,[4]=4,[5]=5}

world.__draw_order = 1;
world.blocks = {}
world.collisions = {} -- Records all of the collisions that happened the last update
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
world.gravity = vector(0, world:to_pixels(9.1));

local function sort_by_depth(a, b)
    return a.depth < b.depth;
end

function world:add(info)
    local index = #self.blocks+1
    local depth = info.depth or index;
    local body_id, body = ECS:new_component("body", "world", id, info.x+info.w/2, info.y+info.h/2, info.w, info.h, -1, info.friction or 0.2, info.bounciness or 0) -- -1 for mass to indicate this is a static body
    self.blocks[index] = setmetatable({body_id = body_id, body=body, depth = depth, id = index}, self._blocks_mt);
    table.sort(self, sort_by_depth);
    return index
end

function world:destroy(block_id)
    -- does nothing, for now.
end

function world:draw()
    love.graphics.setColor(0.7,0.8,0.5,1);
    for k = 1, #self.blocks do
        local v = self.blocks[k];
        love.graphics.rectangle("fill", v.body.pos.x-v.body.w/2, v.body.pos.y-v.body.h/2, v.body.w, v.body.h);
    end
end

function world:update(dt)
    -- handle the previous collisions then delete them.
    for k,v in pairs(self.blocks) do
        -- Do stuff
        for k2,v2 in pairs(v.body.last_collided_with) do
            -- But for now it does nothing
        end
    end
end

return world;