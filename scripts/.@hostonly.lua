local explosionKeybind = keybinds:newKeybind("Explosion", "key.keyboard.delete")

if avatar:getComplexity() > 2048 then
    log("Complexity higher than default max (" .. avatar:getComplexity() .. " / 2048)")
end

destructionIsEnabled = false
destructionTimer = 0

local throwCommand = "summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}"
local waterParticleCommand = "particle dust 0.141 0.800 1.000 1 %f %f %f 10 10 10 1 10000 force"

function fill(x1, y1, z1, x2, y2, z2, block)
    local fillCommand = "fill %s %s %s %s %s %s %s"

    host:sendChatCommand(string.format(fillCommand, math.round(x1), math.round(y1), math.round(z1), math.round(x2), math.round(y2), math.round(z2), block))
end

fireKeybind = keybinds.newKeybind(keybinds, "Fire", "key.keyboard.insert")
extinguishKeybind = keybinds.newKeybind(keybinds, "Extinguish", "key.keyboard.home")

events.tick:register(function()
    if destructionTimer == 0 then
        destructionIsEnabled = false
    else
        destructionTimer = destructionTimer - 1
    end

    if explosionKeybind:isPressed() then
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
            player:getEyeHeight(), 0))
        local block, pos, side = raycast:block(eyePos, eyePos + player:getLookDir() * 10000)

        host:sendChatCommand(string.format(
            "summon creeper %f %f %f {ignited:true,Fuse:1,ExplosionRadius:30,Invulnerable:1b}", pos
            .x,
            pos.y, pos.z))
    end

    if fireKeybind:isPressed() then
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
            player:getEyeHeight(), 0))
        local _, pos, _ = raycast:block(eyePos, eyePos + player:getLookDir() * 10000)

        fill(pos.x - 10, pos.y - 10, pos.z - 10, pos.x + 10, pos.y + 10, pos.z + 10, "fire replace air")
    end

    if extinguishKeybind:isPressed() then
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
            player:getEyeHeight(), 0))
        local _, pos, _ = raycast:block(eyePos, eyePos + player:getLookDir() * 10000)

        host:sendChatCommand(string.format(waterParticleCommand, pos.x, pos.y, pos.z))
        fill(pos.x - 10, pos.y - 10, pos.z - 10, pos.x + 10, pos.y + 10, pos.z + 10, "air replace fire")
    end
end, "COMMANDS.TICK")