local pushpellets = {}
pushpellets.pushpellets = {}

local pushpelletcolor = colorutils:neww(210, 120, 120, 255)
local pushpelletspeed = 300;
local pushpelletmass = 200;
local pushpellet_life_time = 1.5;
local global_id = 1;

function pushpellets:add(info)
    -- requires :
    -- info.pos (vector) for start position
    -- info.direction (vector) for direction of pushpellet (* mandatory)
    -- info.name for name of entity type that wants to spawn the pushpellet (*mandatory)
    -- info.id for entity id of the entity that spawns it (*mandatory)
    -- info.giver_body_id for the id of the entity that shot the pushpellet (*mandatory)
    -- info.self_hit_allowed
    -- info.avoid_type
    local w,h = info.w or 2, info.h or 2
    local body_id, body = ECS:new_component(
        "body", "pushpellets", index, info.pos.x or 0, info.pos.y or 0, w, h,
        pushpelletmass, 0, 0, 0.1)
    local m = {body_id=body_id,
        body=body,
        holder={
            name=info.name or error("info.name must be given",2),
            id=info.id or error("ID of the entity of type "..info.name.."not given", 2)
        },
        time_left = pushpellet_life_time,
        }
    if not info.self_hit_allowed and not info.giver_body_id then
        error("Entity spawning pushpellet did not give it's body id (info.giver_body_id)", 2);
    elseif not info.self_hit_allowed then
        ECS.components["body"]:avoid_id(m.body_id, info.giver_body_id);
    end

    if info.avoid_type then
        ECS.components['body']:avoid_category(m.body_id, info.name);
    end
    --ECS.components['body']:avoid_category(m.body_id, "pushpellets");

    m.body.gravity_effect = 1;
    m.body.vel = (info.direction or error('info.direction vector no given', 2))^1 * pushpelletspeed +  (info.shooter_speed or vector(0,0)); -- length = 1
    self.pushpellets[global_id] = m;
    global_id = global_id + 1;

    return global_id-1, m;
end

function pushpellets:destroy(id)
    if self.pushpellets[id] then
        ECS:queue_component_destroy("body", self.pushpellets[id].body_id);
        self.pushpellets[id] = nil;
    end
end

function pushpellets:draw()
    for k,v in pairs(self.pushpellets) do
        love.graphics.setColor(pushpelletcolor)
        sdraw.rectangle("fill", v.body.pos.x-v.body.w/2, v.body.pos.y-v.body.h/2, v.body.w, v.body.h)
        --love.graphics.rectangle("fill", v.body.pos.x-2, v.body.pos.y-2, v.body.w+2, v.body.h+2);
    end
end

function pushpellets:update(dt)
    local to_delete = {}
    for k,v in pairs(self.pushpellets) do
        v.time_left = v.time_left - dt;

        for k2,v2 in pairs(v.body.last_collided_with) do
            --to_delete[k] = true;
            break;
        end

        if v.time_left <= 0 then
            to_delete[k] = true;
        end
    end
    for k,v in pairs(to_delete) do
        ECS:queue_entity_destroy("pushpellets", k);
    end
end

return pushpellets;
