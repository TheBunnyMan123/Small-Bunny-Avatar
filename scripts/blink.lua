local tick = 0
local blinkRate = 4 * 20

local face = models.model.root.Head.Face
local uv = face:getUV()

function events.tick()
    local lookDir = vectors.angleToDir(player:getRot()) * 90
    local sunAngle = getSunAngle()

    tick = tick + 1
    
    if tick % blinkRate == 0 then
        face:setUV(vec(-8, -8) / getTexture("skin"):getDimensions())
    else
        face:setUV(uv)
    end

    -- log(sunAngle, lookDir)--, math.floor((sunAngle - lookDir) * 90))
end