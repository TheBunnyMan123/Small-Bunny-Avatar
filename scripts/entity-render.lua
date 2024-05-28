local group = models:newPart("Snowballs", "World")
local balls = {}
models.snowball.snowball:setVisible(false)

if goofy == nil then return end

---@param entity Entity.any
function events.entity_render(delta, entity)
    if entity:getType() == "minecraft:snowball" then
        if (entity:getPos(delta) - player:getPos(delta)):length() > 2.5 then
            local cube = deepCopy(models.snowball.snowball)
            group:addChild(cube)

            cube:setPos(entity:getPos(delta)*16):setRot(entity:getLookDir() * 360):setVisible(true)
            
            table.insert(balls, cube)
        end
        return true
    end
    if entity:getType() == "minecraft:egg" then
        if (entity:getPos(delta) - player:getPos(delta)):length() > 2.5 then
            local cube = deepCopy(models.egg.egg)
            group:addChild(cube)

            cube:setPos(entity:getPos(delta)*16):setRot(entity:getLookDir() * 360):setVisible(true)
            
            table.insert(balls, cube)
        end
        return true
    end
end

function events.render()
    for k, v in pairs(balls) do
        v:remove()
        k = nil
    end
end