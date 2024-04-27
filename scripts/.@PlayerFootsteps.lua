enableFootsteps = false
local GNLineLib = require("GNLineLib") --[[@as GNLineLib]]

playerColors = {}
footstepUUID = ""
footstepUsername = ""

local lines = {}

storedSteps = {
    --[[
        uuid = {
            {
                start,
                stop
            }
        }
    ]]
}

local tick = 0
function events.tick()
    tick = tick + 1
    if tick % 20 == 0 and enableFootsteps then
        for _, v in pairs(world:getPlayers()) do
            if v:isLoaded() then
                local uuid = v:getUUID()
                if not storedSteps[uuid] then
                    storedSteps[uuid] = {}

                    storedSteps[uuid][1] = {
                        start = v:getPos() + vec(0, 1, 0),
                        stop = v:getPos() + vec(0, 1, 0),
                    }
                else
                    storedSteps[uuid][#storedSteps[uuid] + 1] = {
                        start = storedSteps[uuid][#storedSteps[uuid]].stop,
                        stop = v:getPos() + vec(0, 1, 0),
                    }
                end
            end
        end
    end
end

function events.render()
    for _, v in pairs(lines) do
        v:free()
    end

    if enableFootsteps then
        local plrs = world:getPlayers()
        v = plrs[footstepUsername]
        if not v then return end

        if v:isLoaded() then
            if not playerColors[v:getUUID()] then
                playerColors[v:getUUID()] = vec(
                    math.random(50, 255) / 255, math.random(50, 255) / 255,
                    math.random(50, 255) / 255)
            end

            local uuid = v:getUUID()
            if storedSteps[uuid] then
                for _, w in pairs(storedSteps[uuid]) do
                    table.insert(lines,
                        GNLineLib:new():setA(w.start):setB(w.stop):setColor(playerColors
                        [v:getUUID()])
                        :setWidth(0.1)
                    )
                end
            end
        end
    end
end
