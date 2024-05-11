local tpLocations = {
    FSMPBase = vec(207, 104, -1251),
    PORTALRoom = vec(-23923206, 14, -23687122)
}

local crosshairModels = models:newPart("BunnyCrosshair", "GUI")
crosshairModels:addChild(models.crosshair)
models:removeChild(models.crosshair)

--hide vanilla models
vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

-- vars
moveFirstPersonCamera = false
swingDelay = 0
nameplateOther =
'["",{"text":":rabbit: "},{"text":"Bunny","color":"#40E0D0"},{"text":" :rabbit: "}, {"text":"${badges}"}]'
nameplate_extra = ""
alreadyAfk = false
task = nil
blockBelowCache = {}

local tick = 0
local oldTick = -1
-- customization
local frame = 0
local lines = {}
function events.render(delta, context)
    do
        local windowSize = client:getScaledWindowSize()

        local block, blockPosReal, face = player:getTargetedBlock(true, host:getReachDistance())
        local entity = player:getTargetedEntity(host:getReachDistance())

        local pos = nil

        if entity then
            local yOff = entity:getBoundingBox().y / 2

            pos = entity:getPos(delta):copy():add(0, yOff, 0)
        elseif not block:isAir() then
            pos = block:getPos():copy():add(0.5, 0.5, 0.5)
            -- log(block:getOutlineShape()[1][2])
            local blockPosOffset = vec(0, 0, 0)
            local maxSize = vec(0, 0, 0)
            local minSize = vec(1, 1, 1)
            local totalSize = vec(0, 0, 0)
            for _, v in pairs(block:getOutlineShape()) do
                if v[2]:length() > v[1]:length() then
                    totalSize = totalSize:add(v[2])
                else
                    totalSize = totalSize:add(v[1])
                end

                if v[1].x < minSize.x then
                    minSize.x = v[1].x
                end
                if v[1].y < minSize.y then
                    minSize.y = v[1].y
                end
                if v[1].z < minSize.z then
                    minSize.z = v[1].z
                end

                if v[2].x > maxSize.x then
                    maxSize.x = v[2].x
                end
                if v[2].y > maxSize.y then
                    maxSize.y = v[2].y
                end
                if v[2].z > maxSize.z then
                    maxSize.z = v[2].z
                end
            end
            
            for k, v in pairs(lines) do
                v:free()
                table.remove(lines, k)
            end

            totalSize = ((maxSize - minSize) / 2) + minSize
            local blockPos = block:getPos() + totalSize

            if face == "north" or face == "south" then
                pos = vec(blockPos.x, blockPos.y, blockPosReal.z)
            elseif face == "east" or face == "west" then
                pos = vec(blockPosReal.x, blockPos.y, blockPos.z)
            elseif face == "up" or face == "down" then
                pos = vec(blockPos.x, blockPosReal.y, blockPos.z)
            end
        else
            pos = nil
        end
        
        if pos then
            local onScreenCoords = vectors.worldToScreenSpace(pos):copy().xy:add(1, 1):mul(client:getScaledWindowSize()):div(-2, -2)

            crosshairModels:setPos(onScreenCoords:unpack()):setVisible(true):setScale(15 / vectors.worldToScreenSpace(pos).w)--:light(15)
        else
            -- renderer:setCrosshairOffset()
            crosshairModels:setVisible(false)
        end
    end

    models.model.root:setScale(0.7)

    local jetpackOn = ((player:getGamemode() == "CREATIVE") or (player:getItem(5).id == "minecraft:elytra"))
    
    models.model.root.Body.Jetpack:setVisible(jetpackOn)

    local smokeOn = (not player:isOnGround() and jetpackOn and context ~= "FIRST_PERSON")

    do
        local date = client:getDate()
        
        ---comment
        ---@param part ModelPart
        local function changeTexture(part, txture)
            for _, v in pairs(part:getChildren()) do
                changeTexture(v, txture)
                
                v:setPrimaryTexture("CUSTOM", getTexture(txture))
            end
        end

        if date.month == 10 then
            jetpackOn = false
            smokeOn = false
            
            models.model.root.Body.Jetpack:setVisible(false)

            changeTexture(models.model.root, "skin_halloween")
        end
    end
    
    if smokeOn and not minimal then
        local smokePivotLeft = models.model.root.Body.Jetpack.SmokePivotLeft
        local smokePivotRight = models.model.root.Body.Jetpack.SmokePivotRight
        local plrRot = player:getLookDir()
        local fireTimeOff = player:getVelocity():length()

        particles:newParticle("minecraft:smoke", smokePivotLeft:partToWorldMatrix():apply(0,0,0),vec(0,-0.2,0)):setScale(0.25)
        particles:newParticle("minecraft:smoke", smokePivotRight:partToWorldMatrix():apply(0,0,0),vec(0,-0.2,0)):setScale(0.25)
        particles:newParticle("minecraft:flame", smokePivotLeft:partToWorldMatrix():apply(0,0,0), vec(0,-0.2,0)):setLifetime(4 - fireTimeOff):setScale(0.5)
        particles:newParticle("minecraft:flame", smokePivotRight:partToWorldMatrix():apply(0,0,0), vec(0,-0.2,0)):setLifetime(4 - fireTimeOff):setScale(0.5)
    end
end

function events.tick()
    tick = tick + 1
    if swingDelay > 0 then
        swingDelay = swingDelay - 1
    end
end

function events.entity_init()
    for _, v in pairs(world:getPlayers()) do
        if v:getName() == "TheKillerBunny" then
            followEntity = v
        end
    end
end