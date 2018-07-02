local bullets = {}
bullets.bullets = {}

local bulletcolor = colorutils:neww(210, 185, 185, 255)
local bulletspeed = 100
function bullets:add(info)
    local index = #self.bullets+1
    local body_id, body = ECS:new_component("body", "bullets", index, info.x or 0, info.y or 0, info.w or 3, info.h or 3)
    local m = {body_id=body_id, body=body, holder={name=info.name or error("info.name must be given",2), id=info.id or 1}}
    m.body.gravity_effect = 0.01;
    m.body.vel = (vector:new(info.direction_x or 1, info.direction_y or 1)^1) * bulletspeed;
    self.bullets[#self.bullets+1] = m;
end

function bullets:destroy(id)
    ECS:queue_component_destroy("body", self.bullets[id].body_id);
    table.remove(self.bullets, id);
end

function bullets:draw()
    for k,v in pairs(self.bullets) do
        love.graphics.setColor(bulletcolor)
        love.graphics.rectangle("fill", v.body.pos[1], v.body.pos[2], v.body.w, v.body.h);
    end
end

function bullets:update(dt)
    local to_delete = {}
    for k,v in pairs(self.bullets) do
        for k2,v2 in pairs(v.body.last_collided_with) do
            if (v2[1]~="world" and not (v.holder.name == v2[1] and v.holder.id==v2[2])) then
                ECS:queue_entity_destroy(v2[1], v2[2]);
                print("Queuing for destruction after bullet attack : ", v2[2], v2[1]);
                to_delete[k] = true;
            end
        end
    end
    for k,v in pairs(to_delete) do
        table.remove(self.bullets, k)
    end
end

return bullets;