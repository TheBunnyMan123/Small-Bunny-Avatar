drone = models.drone.World

local GNLineLib = require("GNLineLib") --[[@as GNLineLib]]
local lines = {}

customTarget = nil

local targetPos
local currentPos --drone:getTruePos()

local posDelta = vec(0, 0, 0)

local rotAngle = vec(0, 0, 0)
local rotAngleOld = vec(0, 0, 0)

function pings.dronepos(pos)
    if not pos then customTarget = nil end

    log("pos set to ", pos)
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

followEntity = nil

function pings.setDroneFollow(entity)
    for _, v in pairs(world:getPlayers()) do
        if v:getName() == entity then
            followEntity = v
        end
    end
end

function events.tick()
    for _, v in pairs(lines) do
        v:free()
    end

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

    if not followEntity then return end
    if not followEntity:isLoaded() then return end
    if customTarget then
        targetPos = customTarget * 16
    else
        targetPos = (followEntity:getPos() + vec(0, 2.5, 0)) * 16
    end
    currentPos = drone:getPos()

    posDelta = targetPos - currentPos

    rotAngleOld = rotAngle
    rotAngle = calcRot(currentPos, targetPos)
end

function events.render(delta, context, matrix)
    if not currentPos or not posDelta or not rotAngle or not rotAngleOld then return end
    drone:setVisible(not context:find("GUI"))

    drone:setPos(math.lerp(currentPos, currentPos + (posDelta / 10), delta))
    drone:setRot(math.lerpAngle(rotAngleOld, rotAngle, delta))

    entities.drone = {
        pos = ((models.drone.World:getTruePos() + models.drone.World:getTruePivot()) / 16),
        hitbox = {
            (vec(5.5, 3, 5.5) * -1) / 16,
            vec(5.5, 3, 5.5) / 16,
        },
    }
    
    -- table.insert(lines, GNLineLib:new():setAB(entities.drone.pos + entities.drone.hitbox[1], entities.drone.pos + entities.drone.hitbox[2]):setWidth(0.1))
end

function events.entity_init()
    for _, v in pairs(world:getPlayers()) do
        if v:getName() == "TheKillerBunny" then
            followEntity = v
        end
    end
end
