local bullets = {}
bullets.bullets = {}

local bulletcolor = colorutils:neww(210, 185, 185, 255)
local bulletspeed = 100
function bullets:add(info)
    -- requires :
    -- info.pos (vector) for start position
    -- info.direction (vector) for direction of bullet
    -- info.name for name of entity type (*mandatory)
    -- info.id for entity id of the entity that spawns it (*mandatory)
    -- info.giver_body_id for the id of the entity that shot the bullet (*mandatory)
    -- info.self_hit_allowed
    local index = #self.bullets+1
    local body_id, body = ECS:new_component("body", "bullets", index, info.pos[1] or 0, info.pos[2] or 0, info.w or 3, info.h or 3)
    local m = {body_id=body_id, body=body, holder={name=info.name or error("info.name must be given",2), id=info.id or error("ID of the entity of type "..info.name.."not given", 2)}}
    if not info.self_hit_allowed and not info.giver_body_id then
        error("Entity spawning bullet did not give it's body id (info.giver_body_id)", 2);
    elseif not info.self_hit_allowed then
        ECS.components["body"]:avoid_id(m.body_id, info.giver_body_id);
    end

    m.body.gravity_effect = 0.01;
    m.body.vel = info.direction/(vector.getlength(info.direction)) * bulletspeed; -- length = 1
    self.bullets[#self.bullets+1] = m;
end

function bullets:destroy(id)
    if self.bullets[id] then
        ECS:queue_component_destroy("body", self.bullets[id].body_id);
        table.remove(self.bullets, id);
    end
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
                to_delete[k] = true;
            end
        end
    end
    for k,v in pairs(to_delete) do
        ECS:queue_entity_destroy("bullets", k);
    end
end

return bullets;