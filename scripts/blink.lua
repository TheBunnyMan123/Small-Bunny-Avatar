disableBlur = false

local tick = 0
local blinkRate = 4 * 20
local sunTicks = 0

local face = models.model.root.Head.Face
local uv = face:getUV()

--getSunDir provided by https://github.com/GrandpaScout/GSExtensions/blob/ebdbc6c109a77a9d332507a2acf9db8ab6de41e7/scripts/GSE_World.lua#L110-L121

local day_divisor = 1 / 24000
--- Taken straight from Minecraft's source.
local sun_magic = 6.2831855 / 3
local _VEC_UP = vectors.vec3(0, 1)
local _VEC_SOUTH = vectors.vec3(0, 0, 1)

function getSunDir(delta)
    local frac = (world.getTimeOfDay(delta) * day_divisor - 0.25) % 1
    return vectors.rotateAroundAxis(
      math.deg((frac * 2 + (0.5 - math.cos(frac * math.pi) * 0.5)) * sun_magic),
      _VEC_UP,
      _VEC_SOUTH
    )
end

function lookingAtSun()
    local lookDir = player:getLookDir()
    local sunDir = getSunDir()

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

function events.tick()
    if player:isLoaded() then
        if lookingAtSun() then
            blinkRate = 1.5 * 20
            sunTicks = sunTicks + 1
            renderer:setPostEffect("phosphor")
        elseif not disableBlur then
            sunTicks = 0
            blinkRate = 4 * 20
            renderer:setPostEffect()
        end

        tick = tick + 1

        if tick % blinkRate == 0 then
            face:setUV(vec(-8, -8) / getTexture("skin"):getDimensions())
        else
            face:setUV(uv)
        end
    end
end