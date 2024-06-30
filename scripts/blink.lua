disableBlur = false

local tick = 0
local blinkRate = 4 * 20
local sunTicks = 0

local face = models.model.root.Head.Face
local uv = face:getUV()

function events.tick()
    if player:isLoaded() then
        if world.lookingAtSun() then
            blinkRate = 1.5 * 20
            sunTicks = sunTicks + 1
            if client.getVersion() ~= '1.21' then
                renderer:setPostEffect("phosphor")
            end
        elseif not disableBlur then
            sunTicks = 0
            blinkRate = 4 * 20
            sunTicks = sunTicks + 1
            if client.getVersion() ~= '1.21' then
                renderer:setPostEffect()
            end
        end

        tick = tick + 1

        if tick % blinkRate == 0 then
            face:setUV(vec(-8, -8) / getTexture("skin"):getDimensions())
        else
            face:setUV(uv)
        end
    end
end