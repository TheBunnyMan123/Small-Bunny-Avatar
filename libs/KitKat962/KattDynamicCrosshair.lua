--================================================--
--   _  ___ _    ____      _    ___   __  ____    --
--  | |/ (_) |_ / ___|__ _| |_ / _ \ / /_|___ \   --
--  | ' /| | __| |   / _` | __| (_) | '_ \ __) |  --
--  | . \| | |_| |__| (_| | |_ \__, | (_) / __/   --
--  |_|\_\_|\__|\____\__,_|\__|  /_/ \___/_____|  --
--                                                --
--================================================--

--v3.0

local customCrosshair = ...
local model = models:newPart("Katt$DynamicCrosshair", "GUI")
if type(customCrosshair) == "ModelPart" then
  local p = customCrosshair:getParent()
  if p then p:removeChild(customCrosshair) end
  model:addChild(customCrosshair)
  renderer:setRenderCrosshair(false)
  customCrosshair = true
else
  renderer:setRenderCrosshair(true)
  customCrosshair = false
end
local pos = vectors.vec3()

local function validBlock(block)
  return block and not block:isAir()
end
function events.ENTITY_INIT() pos:set(player:getPos()) end

---@class KattDynamicCrosshairAPI
---@field render fun(model:ModelPart, pos:Vector3, target:Entity|BlockState, screenCoords:Vector2)
local api = {}

function events.RENDER(delta)
  local entity, entityPos = player:getTargetedEntity(host:getReachDistance())
  local block, blockPos = player:getTargetedBlock(true, host:getReachDistance())
  local deltaDeltaPos = player:getPos(delta) - player:getPos()
  local targetPos = entity and entityPos:add(deltaDeltaPos)
      or validBlock(block) and blockPos:add(deltaDeltaPos)
      or player:getPos(delta)
      :add(0, player:getEyeHeight())
      :add(player:getLookDir() * host:getReachDistance())
  pos:set(math.lerp(pos, targetPos, 0.35))

  local screenSpace = vectors.worldToScreenSpace(pos)

  local coords = screenSpace.xy:add(1, 1):mul(client:getScaledWindowSize()):div(-2, -2)
  model:setPos(coords.xy_)
      :setVisible(screenSpace.z >= 1)
      :setScale(3 / screenSpace.w)
  if not customCrosshair then
    renderer:setCrosshairOffset(screenSpace.xy:mul(client:getScaledWindowSize()):div(2, 2))
  end

  if api.render then api.render(model, pos, entity or block, coords) end
end

return api
