drone = models.drone.World

local GNLineLib = require("GNLineLib") --[[@as GNLineLib]]
local lines = {}

customTarget = nil

local targetPos
local currentPos --drone:getTruePos()

local posDelta = vec(0, 0, 0)

local rotAngle = vec(0, 0, 0)
local rotAngleOld = vec(0, 0, 0)

controlDrone = false

local forwardKeybind = keybinds:newKeybind("droneForward", "key.keyboard.up")
local boostKeybind = keybinds:newKeybind("droneBoost", "key.keyboard.page.down")
local backKeybind = keybinds:newKeybind("droneBackwards", "key.keyboard.down")

local forceRenderPart = models:newPart("ForceRender", "LeftArm"):scale(1,1,1)

function setParentType(model, type)
    model:setParentType(type)
    for k, v in pairs(model:getChildren()) do
        setParentType(v, type)
        model:getChildren()[k]:setParentType(type)
    end
end

function pings.dronepos(pos)
    if not pos then customTarget = nil end

    -- log("pos set to ", pos)
    customTarget = pos
end

function calcRot(dronePos, playerPos)
    -- Calculate the direction vector from drone to player
    local dirVec = playerPos - dronePos

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

followPlrName = ""

function pings.setDroneFollow(e)
    followPlrName = e
end

local tick = 0
local oldTick = -1

function events.world_tick()
    tick = tick + 1

    for _, v in pairs(lines) do
        v:free()
    end

    if not controlDrone then
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
            if string.lower(v:getName()) ~= string.lower(followPlrName) then goto continue end
            if customTarget then
                targetPos = customTarget * 16
            else
                targetPos = (v:getPos() + vec(0, 2.5, 0)) * 16
            end
            currentPos = drone:getPos()

            posDelta = targetPos - currentPos

            rotAngleOld = rotAngle
            rotAngle = calcRot(currentPos, targetPos)
            ::continue::
        end
    end

    if controlDrone then
        local oldTargetPos = targetPos
        currentPos = drone:getTruePos()
        targetPos = currentPos
        if forwardKeybind:isPressed() then
            targetPos = targetPos +
            player:getLookDir() * 100 * (boostKeybind:isPressed() and 10 or 1)
        end
        if backKeybind:isPressed() then
            targetPos = targetPos +
            player:getLookDir() * -100 * (boostKeybind:isPressed() and 10 or 1)
        end

        rotAngleOld = rotAngle
        rotAngle = calcRot(currentPos, targetPos)
        posDelta = targetPos - currentPos
    end
end

function events.world_render(delta)
    if not currentPos or not posDelta or not rotAngle or not rotAngleOld then return end
    -- drone:setVisible(not context:find("GUI") and not controlDrone)
    if controlDrone then
        drone:setVisible(not renderer:isFirstPerson())
    else
        drone:setVisible(true)
    end

    local prevPos = drone:getPos()
    local nextPos = math.lerp(currentPos, currentPos + (posDelta / 10), delta)
    drone:setPos(nextPos)
    drone:setRot(math.lerpAngle(rotAngleOld, rotAngle, delta))

    entities.drone = {
        pos = ((models.drone.World:getTruePos() + models.drone.World:getTruePivot() - vec(0, 3, 0)) / 16),
        hitbox = {
            (vec(5.5, 0, 5.5) * -1) / 16,
            vec(5.5, 6, 5.5) / 16,
        },
    }

    if controlDrone then
        if renderer:isFirstPerson() then
            vanilla_model.PLAYER:setVisible(true):setScale(0.7)
            models.model:setPos(player:getPos(delta) * 16):setParentType("World"):setRot(0, player:getBodyYaw(delta) * -1 + 180, 0)
        else
            vanilla_model.PLAYER:setVisible(false):setScale()
            models.model:setPos():setParentType("Model"):setRot()
        end

        renderer:setCameraPivot(drone:getTruePos() / 16)

        -- if not table.contains({"minecraft:air", "minecraft:water", "minecraft:lava"}, world.getBlockState(nextPos / 16):getID()) then
        --     targetPos = prevPos
        --     drone:setPos(prevPos)
        -- end

        if not table.contains({"minecraft:air", "minecraft:water", "minecraft:lava", "minecraft:kelp_plant", "minecraft:tall_seagrass"}, world.getBlockState(entities.drone.pos + entities.drone.hitbox[1]):getID()) then
            targetPos = prevPos
            drone:setPos(prevPos)
        end

        if not table.contains({"minecraft:air", "minecraft:water", "minecraft:lava"}, world.getBlockState(entities.drone.pos + entities.drone.hitbox[2]):getID()) then
            targetPos = prevPos
            drone:setPos(prevPos)
        end

        if tick % 10 == 0 and oldTick ~= tick then
            pings.dronepos(drone:getPos() / 16)
        end

        if tick % 10 == 0 and oldTick ~= tick then
            pings.dronepos(drone:getTruePos() / 16)
            oldTick = tick
        elseif oldTick ~= tick then
            oldTick = tick
        end
    else
        vanilla_model.PLAYER:setVisible(false):setScale()
        renderer:setCameraPivot()
        if tick % 10 == 0 and oldTick ~= tick then
            pings.dronepos(nil)
            oldTick = tick
        elseif oldTick ~= tick then
            oldTick = tick
        end

        models.model:setPos():setParentType("Model"):setRot()
    end
    
    -- drone:setVisible(true)
end

followPlrName = "TheKillerBunny"
