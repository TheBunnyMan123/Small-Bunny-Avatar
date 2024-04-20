drone = models.drone.World

local targetPos 
local currentPos --drone:getTruePos()

local posDelta = vec(0, 0, 0)

local rotAngle = vec(0, 0, 0)
local rotAngleOld = vec(0, 0, 0)

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

function events.tick()
    if not followEntity then return end
    if not followEntity:isLoaded() then return end
    targetPos = (followEntity:getPos() + vec(0, 1, 0)) * 16
    currentPos = drone:getPos()

    posDelta = targetPos - currentPos

    rotAngleOld = rotAngle
    rotAngle = calcRot(currentPos, targetPos)
end

function events.render(delta, context, matrix)
    if not currentPos or not posDelta or not rotAngle or not rotAngleOld then return end 
    drone:setVisible(context ~= "FIRST_PERSON" and not context:find("GUI"))

    drone:setPos(math.lerp(currentPos, currentPos + (posDelta / 10), delta))
    drone:setRot(math.lerpAngle(rotAngleOld, rotAngle, delta))
    -- drone:setRot(rotAngle)
end
