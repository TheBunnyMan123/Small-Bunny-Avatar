---@diagnostic disable: undefined-field

--world.getSunDir provided by https://github.com/GrandpaScout/GSExtensions/blob/ebdbc6c109a77a9d332507a2acf9db8ab6de41e7/scripts/GSE_World.lua#L110-L121
local day_divisor = 1 / 24000
--- Taken straight from Minecraft's source.
local sun_magic = 6.2831855 / 3
local _VEC_UP = vectors.vec3(0, 1)
local _VEC_SOUTH = vectors.vec3(0, 0, 1)

figuraMetatables.WorldAPI.__index.getSunDir = function()
    local frac = (world.getTimeOfDay() * day_divisor - 0.25) % 1
    return vectors.rotateAroundAxis(
      math.deg((frac * 2 + (0.5 - math.cos(frac * math.pi) * 0.5)) * sun_magic),
      _VEC_UP,
      _VEC_SOUTH
    )
end

function figuraMetatables.WorldAPI.__index.lookingAtSun()
    local lookDir = player:getLookDir()
    local sunDir = world.getSunDir()

    local eyePos = player:getPos():add(0, player:getEyeHeight(), 0)
    local block, pos, side = raycast:block(eyePos, eyePos + player:getLookDir() * 10000, "VISUAL", "ANY")

    if disableBlur then
        return false
    end

    if not block:isTranslucent() then
        return false
    end
    
    return pointOnPlane(vec(-15, -15, -15), vec(15, 15, 15), ((sunDir - lookDir) * 180):floor())
end