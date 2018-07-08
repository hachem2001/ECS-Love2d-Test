local bullets = {}
bullets.bullets = {}

local bulletcolor = colorutils:neww(210, 0, 0, 255)
local bulletspeed = 100;
local bulletmass = 200;
local bullet_life_time = 5;
local global_id = 1;

function bullets:add(info)
    -- requires :
    -- info.pos (vector) for start position
    -- info.direction (vector) for direction of bullet (* mandatory)
    -- info.name for name of entity type that wants to spawn the bullet (*mandatory)
    -- info.id for entity id of the entity that spawns it (*mandatory)
    -- info.giver_body_id for the id of the entity that shot the bullet (*mandatory)
    -- info.self_hit_allowed
    -- info.avoid_type
    local body_id, body = ECS:new_component("body", "bullets", global_id, info.pos.x or 0, info.pos.y or 0, info.w or 3, info.h or 3, bulletmass)
    local m = {body_id=body_id,
        body=body,
        holder={
            name=info.name or error("info.name must be given",2),
            id=info.id or error("ID of the entity of type "..info.name.."not given", 2)
        },
        time_left = bullet_life_time,
        }
    if not info.self_hit_allowed and not info.giver_body_id then
        error("Entity spawning bullet did not give it's body id (info.giver_body_id)", 2);
    elseif not info.self_hit_allowed then
        ECS.components["body"]:avoid_id(m.body_id, info.giver_body_id);
    end

    if info.avoid_type then
        ECS.components['body']:avoid_category(m.body_id, info.name);
    end

    m.body.vel = (info.direction or error('info.direction vector no given', 2))^bulletspeed; -- length = 1
    self.bullets[global_id] = m;
    global_id = global_id + 1;
    return global_id-1, m;
end

function bullets:destroy(id)
    if true then
    return false;
    end
    if self.bullets[id] then
        ECS:queue_component_destroy("body", self.bullets[id].body_id);
        self.bullets[id] = nil;
    end
end

function bullets:draw()
    for k,v in pairs(self.bullets) do
        love.graphics.setColor(bulletcolor);
        sdraw.rectangle("fill", v.body.pos.x, v.body.pos.y, v.body.w, v.body.h);
        --love.graphics.rectangle("fill", v.body.pos[1], v.body.pos[2], v.body.w, v.body.h);
    end
end

function bullets:update(dt)
    local to_delete = {}
    for k,v in pairs(self.bullets) do
        v.time_left = v.time_left - dt;

        for k2,v2 in pairs(v.body.last_collided_with) do
            if (v2[1]~="world" and not (v.holder.name == v2[1] and v.holder.id==v2[2])) then
                ECS:queue_entity_destroy(v2[1], v2[2]);
                to_delete[k] = true;
            elseif (v2[1]=='world') then
                to_delete[k] = true;
            end
        end

        if v.time_left <= 0 then
            to_delete[k] = true;
        end
    end
    for k,v in pairs(to_delete) do
        ECS:queue_entity_destroy("bullets", k);
    end
end

return bullets;