local laserKeybind = keybinds:newKeybind("Laser", "key.keyboard.page.up")
local lineLib = require("GNLineLib")

local line
local line2

function pings.line(pos1, pos2)
    line2 = lineLib:new():setA(pos1:unpack()):setB(pos2:unpack()):setColor(1, 0.2, 0.2, 1):setWidth(0.4):setDepth(0.1)
    line = lineLib:new():setA(pos1:unpack()):setB(pos2:unpack()):setColor(1, 1, 1, 1):setWidth(0.3):setDepth(0.2)
end

function pings.free()
    if line then line:free() end
    if line2 then line2:free() end
end

local tick = 0
function events.tick()
    tick = tick + 1
    if tick % 5 == 0 then if line then pings.free() end end
    if laserKeybind:isPressed() and host:isHost() then
        if not destructionIsEnabled then
            logJson(
                    toJson(
                    {
                        {
                            text = "Destruction",
                            color = "red",
                            bold = true
                        },
                        {
                            text = " is not enabled!",
                            color = "gray",
                            bold = false
                        }
                    }
                    )
                )
                return
        end
    
        destructionTimer = 60

        local eyePos = player:getPos():add(vec(0,
            player:getEyeHeight() - 0.5, 0))
        local _, pos, _ = raycast:block(eyePos, eyePos + player:getLookDir() * 10000)

        host:sendChatCommand(('summon tnt %f %f %f'):format(pos:unpack()))

        if tick % 5 == 0 then pings.line(eyePos, pos) end
    end
end