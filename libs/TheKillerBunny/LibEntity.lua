--https://discord.com/channels/1129805506354085959/1238741581956120576
--[[
     _     _ _     _____       _   _ _
    | |   (_) |__ | ____|_ __ | |_(_) |_ _   _
    | |   | | '_ \|  _| | '_ \| __| | __| | | |
    | |___| | |_) | |___| | | | |_| | |_| |_| |
    |_____|_|_.__/|_____|_| |_|\__|_|\__|\__, |
    by TheKillerBunny                    |___/
]]

---@class LibEntity
local LibEntityFuncs = {}
local CustomEntities = {}

---@class LibEntity.Entity
---@field name string
---@field position Vector3
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

    CustomEntities[entity.name] = entity

    return entity
end

---Set the position of a custom entity (should be bottom center of entity)
---@param self LibEntity.Entity
---@param position Vector3
function customEntity.setPos(self, position)
    self.position = position
end

---Set an entity's hitbox
---@param self LibEntity.Entity
---@param hitbox [Vector3, Vector3]
function customEntity.setHitbox(self, hitbox)
    self.hitbox = hitbox
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
                w.position = w.pos
                w.pos = nil
                
                table.insert(entities, w)
            end
        end
    end

    return entities
end

events.render:register(function()
    local entities = {}

    for _, v --[[@as LibEntity.Entity]] in pairs(CustomEntities) do
        table.insert(entities, {
            pos = v.position,
            hitbox = v.hitbox
        })
    end

    avatar:store("entities", entities)
end, "LibEntity.RENDER")

return LibEntityFuncs