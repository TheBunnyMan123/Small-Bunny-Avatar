--https://discord.com/channels/1129805506354085959/1238741581956120576
--[[
     _     _ _     _____       _   _ _
    | |   (_) |__ | ____|_ __ | |_(_) |_ _   _
    | |   | | '_ \|  _| | '_ \| __| | __| | | |
    | |___| | |_) | |___| | | | |_| | |_| |_| |
    |_____|_|_.__/|_____|_| |_|\__|_|\__|\__, |
    by TheKillerBunny                    |___/
]]

local function stringsplit(input, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. seperator .. "]+)") do
        table.insert(t, str)
    end
    return t
end

---@alias LibEntity.AItype "NONE"|"DRONE"|"FOLLOW"
---@alias LibEntity.AI {ai: LibEntity.AItype, modifier?: string}

---@class LibEntity
local LibEntityFuncs = {}
local CustomEntities = {}

local function calcRot(entityPos, targetPos)
    -- Calculate the direction vector from drone to player
    local dirVec = targetPos - entityPos

    -- Check for near-zero x-component
    if math.abs(dirVec.x) < 0.01 then
        -- If x is near zero, use a small positive value to avoid division by zero
        dirVec.x = 0.01
    end

    -- Flatten the direction vector to the horizontal plane (y = 0)
    dirVec.y = 0

    -- Calculate the angle in degrees between the positive z-axis and the direction vector
    local angle = math.atan2(dirVec.x, dirVec.z) * (180 / math.pi)

    -- Convert the angle to a vector suitable for setRot
    local rotVec = vec(0, angle - 180, 0)

    -- Return the rotation vector
    return rotVec
end

local AIFunctions = {}
AIFunctions = {
    ---@param entity LibEntity.Entity
    ---@param drone ModelPart
    ---@param target string
    ---@param customTarget Vector3?
    droneTick = function(entity, drone, target, customTarget)
        drone:light(15)
        for _, v in pairs(drone:getChildren()) do
            v:light(15)
            for _, w in pairs(v:getChildren()) do
                w:light(15)
                for _, x in pairs(w:getChildren()) do
                    x:light(15)
                end
            end
        end

        for _, v in pairs(world:getPlayers()) do
            if not v:isLoaded() then goto continue end

            if customTarget then
                entity.__vars.targetPos = customTarget * 16
            else
                if string.lower(v:getName()) ~= string.lower(target) then goto continue end
                entity.__vars.targetPos = (v:getPos() + vec(0, 2.5, 0)) * 16
            end

            entity.__vars.currentPos = drone:getPos()
    
            entity.__vars.posDelta = entity.__vars.targetPos - entity.__vars.currentPos

            entity.__vars.rotAngleOld = (entity.__vars.rotAngle or vec(0, 0, 0))
            entity.__vars.rotAngle = calcRot(entity.__vars.currentPos, entity.__vars.targetPos)
            ::continue::
        end
    end,

    droneRender = function(entity, drone, delta)
        if entity.__vars.posDelta then
            local prevPos = drone:getPos()
            local nextPos = math.lerp(entity.__vars.currentPos, entity.__vars.currentPos + (entity.__vars.posDelta / 10), delta)
            drone:setPos(nextPos)
            drone:setRot(math.lerpAngle(entity.__vars.rotAngleOld, entity.__vars.rotAngle, delta))

            entity:setPos((drone:getTruePos() + drone:getTruePivot() - vec(0, 3, 0)) / 16)
        end
    end,

    followTick = function(entity, model, target)
        for _, v in pairs(model:getChildren()) do
            v:light(15)
            for _, w in pairs(v:getChildren()) do
                w:light(15)
                for _, x in pairs(w:getChildren()) do
                    x:light(15)
                end
            end
        end

        for _, v in pairs(world:getPlayers()) do
            if not v:isLoaded() then goto continue end
            if string.lower(v:getName()) ~= string.lower(target) then goto continue end

            entity.__vars.targetPos = ((v:getPos() + vec(0, 2.5, 0)) * 16)

            entity.__vars.currentPos = model:getPos()

            local absPosUnrounded = (entity.__vars.currentPos:copy() / 16)
            local absolutePos = absPosUnrounded:copy():floor()
            local blockMapUp = world.getBlocks(absolutePos, vec(absolutePos.x, world.getBuildHeight(), absolutePos.z))
            local blockMapDown = world.getBlocks(absolutePos, vec(absolutePos.x, -64, absolutePos.z))
            if blockMapUp[1]:isSolidBlock() then
                for _, w in ipairs(blockMapUp) do
                    if not w:isSolidBlock() then
                        entity.__vars.targetPos = vec(entity.__vars.targetPos.x, w:getPos().y * 16, entity.__vars.targetPos.z)
                        goto endIfs
                    end
                end
            elseif not blockMapDown[2]:isSolidBlock() then
                for i = #blockMapDown, -1, 1 do
                    if not blockMapDown[i]:isSolidBlock() then
                        entity.__vars.targetPos = vec(entity.__vars.targetPos.x, blockMapDown[i]:getPos().y, entity.__vars.targetPos.z)
                        goto endIfs
                    end
                end
            else
                entity.__vars.targetPos = vec(entity.__vars.targetPos.x, entity.__vars.currentPos.y, entity.__vars.targetPos.z)
            end
            ::endIfs::
    
            entity.__vars.posDelta = entity.__vars.targetPos - entity.__vars.currentPos

            entity.__vars.rotAngleOld = (entity.__vars.rotAngle or vec(0, 0, 0))
            entity.__vars.rotAngle = calcRot(entity.__vars.currentPos, entity.__vars.targetPos)
            ::continue::
        end
    end,

    followRender = function(entity, model, delta)
        if entity.__vars.posDelta then
            local nextPos = math.lerp(entity.__vars.currentPos, entity.__vars.currentPos + (entity.__vars.posDelta / 10), delta)

            model:setPos(nextPos)
            model:setRot(math.lerpAngle(entity.__vars.rotAngleOld, entity.__vars.rotAngle, delta))

            entity:setPos((model:getTruePos() + model:getTruePivot() - vec(0, 3, 0)) / 16)
        end
    end
}

---@class LibEntity.Entity
---@field name string
---@field position Vector3
---@field ai LibEntity.AI
---@field model ModelPart
---@field __vars table
---@field hitbox [Vector3, Vector3]
local customEntity = {}
customEntity.__index = customEntity
customEntity.__type = "LibBunny.Entity"

---Create a new custom entity
---@param name string
---@param position? Vector3
---@param hitbox? [Vector3, Vector3]
---@return LibEntity.Entity
function LibEntityFuncs.new(name, position, hitbox)
    local entity = setmetatable({}, customEntity) --[[@as LibEntity.Entity]]
    entity.name = name
    entity.position = (position or vec(0, 0, 0))
    entity.hitbox = (hitbox or {vec(0, 0, 0), vec(0, 0, 0)})
    entity.ai = {ai = "NONE"}
    entity.__vars = {}

    CustomEntities[entity.name] = entity

    return entity
end

---Remove an entity from processing list
---@param self LibEntity.Entity
function customEntity.free(self)
    CustomEntities[self.name] = nil
end

---Set the position of a custom entity (should be bottom center of entity)
---@param self LibEntity.Entity
---@param position Vector3
function customEntity.setPos(self, position)
    self.position = position
    return self
end

---Set an entity's hitbox
---@param self LibEntity.Entity
---@param hitbox [Vector3, Vector3]
---@return LibEntity.Entity
function customEntity.setHitbox(self, hitbox)
    self.hitbox = hitbox
    return self
end

---Give a custom entity a pre set AI
---@param self LibEntity.Entity
---@param ai LibEntity.AItype
---@param model ModelPart
---@param modifier string
function customEntity.setAI(self, ai, model, modifier)
    self.ai = {ai = ai, modifier = modifier}
    self.model = model
end

---Get an entity's pre-set AI
---@param self LibEntity.Entity
---@return LibEntity.AItype, string?
function customEntity.getAI(self)
    local ai = self.ai
    
    return ai.ai, ai.modifier
end

---Get an entity's position
---@param self LibEntity.Entity
---@return Vector3
function customEntity.getPos(self)
    return self.position
end

---Get an entity's hitbox
---@param self LibEntity.Entity
---@return [Vector3, Vector3]
function customEntity.getHitbox(self)
    return self.hitbox
end

---Gets all currently stored custom entities
---@return LibEntity.Entity[]
function LibEntityFuncs.getEntities()
    local entities = {}

    for _, v in pairs(world.avatarVars()) do
        if v.entities then
            for _, w in ipairs(v.entities) do
                table.insert(entities, setmetatable({
                    position = w.pos,
                    hitbox = w.hitbox
                }, customEntity))
            end
        end
    end

    return entities
end

events.tick:register(function()
    for _, v --[[@as LibEntity.Entity]] in pairs(CustomEntities) do
        if v.ai.ai == "DRONE" then
            local split = stringsplit(v.ai.modifier)
            
            pcall(function()
                split[1] = vectors.vec3(table.unpack(stringsplit(split[1], ",")))
            end)

            if type(split[1]) == "string" then
                AIFunctions.droneTick(v, v.model, split[1])
            elseif type(split[1]) == "Vector3" then
                AIFunctions.droneTick(v, v.model, "NotARealPlayerButThisNeedsToBeAString", split[1])
            end
        elseif v.ai.ai == "FOLLOW" then
            AIFunctions.followTick(v, v.model, v.ai.modifier)
        end
    end
end)

events.render:register(function(delta)
    for _, v --[[@as LibEntity.Entity]] in pairs(CustomEntities) do
        if v.ai.ai == "DRONE" then
            local split = stringsplit(v.ai.modifier)

            AIFunctions.droneRender(v, v.model, delta)
        elseif v.ai.ai == "FOLLOW" then
            AIFunctions.followRender(v, v.model, delta)
        end
    end

    local entities = {}

    for _, v --[[@as LibEntity.Entity]] in pairs(CustomEntities) do
        table.insert(entities, {
            pos = v.position,
            hitbox = {
                v.hitbox[1]:copy(),
                v.hitbox[2]:copy()
            }
        })
    end

    avatar:store("entities", entities)
end, "LibEntity.RENDER")

return LibEntityFuncs