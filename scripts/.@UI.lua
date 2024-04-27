local UI = models:newPart("UI", "HUD")
local healthGradient = gradient(vec(255, 85, 85), vec(85, 255, 85), 100)

local GNLineLib = require("GNLineLib") --[[@as GNLineLib]]
local lines = {}

local oldPositions = {
    TheKillerBunny = vec(0, 0, 0),
}
playerColors = {}

enableTracking = false

local oldTick = 0
local tick = 0
function events.tick()
    if tick == 0 then
        oldPositions["TheKillerBunny"] = player:getPos()
    end
    tick = tick + 1
end

function track(delta)
    local toReturn = { { text = "Tracking: ", color = "white" } }
    local iter = 1

    for _, v in pairs(lines) do
        v:free()
    end

    for _, v in pairs(world:getPlayers()) do
        if v:isLoaded() then
            if v:getUUID() == player:getUUID() then
                goto continue
            end

            iter = iter + 1
            -- log(oldPositions[v:getUUID()])
            if not oldPositions[v:getUUID()] then oldPositions[v:getUUID()] = v:getPos() end
            if not playerColors[v:getUUID()] then playerColors[v:getUUID()] = vec(
                math.random(50, 255) / 255, math.random(50, 255) / 255, math.random(50, 255) / 255) end

            -- log(delta, math.lerp(oldPositions[v:getUUID()] + vec(0, 1, 0), v:getPos() + vec(0, 1, 0),
            -- delta), oldPositions[v:getUUID()], v:getPos() + vec(0, 1, 0))

            -- if oldPositions[v:getUUID()] == v:getPos() then log("BAD") end

            if enableTracking then
                lines[iter] = GNLineLib:new():setA( --[[math.lerp(
                    oldPositions["TheKillerBunny"] + vec(0, 1, 0),]]
                        player:getPos() + vec(0, 1, 0), delta) --)
                    :setB(
                    --[[math.lerp(oldPositions[v:getUUID()] + vec(0, 1, 0), ]] v:getPos() +
                    vec(0, 1, 0) --[[,
                            delta)]])
                    :setColor(playerColors[v:getUUID()])
                    :setWidth(0.1)
            end
            table.insert(toReturn,
                { text = "\n" .. v:getName() .. " - " .. tostring(v:getPos():floor()), color = "#" ..
                tostring(vectors.rgbToHex(playerColors[v:getUUID()])) })

            if oldTick < tick then
                -- log(oldPositions[player:getName()],player:getPos())
                -- log(oldPositions[player:getName()]:floor(), player:getPos():floor())
                --
                oldPositions["TheKillerBunny"] = player:getPos()
                -- log(oldPositions[player:getName()]:floor(), player:getPos():floor())
                oldPositions[v:getUUID()] = v:getPos()
                oldTick = tick
            end
        end
        ::continue::
    end

    return toReturn
end

bypassHealth = false
function events.render(delta)
    if not host:isHost() then return end
    local size = client:getScaledWindowSize()

    ::health::

    if not player:getVehicle() or bypassHealth then
        bypassHealth = false

        UI:newText("SideHealth")

        UI:newText("Health"):text(toJson({
            { text = "Health", color = "red" },
            { text = ": ",     color = "gray" },
            {
                text = tostring(math.round(player:getHealth() + player:getAbsorptionAmount())),
                color = (function()
                    local health = player:getHealth() + player:getAbsorptionAmount()
                    local maxHealth = player:getMaxHealth()
                    local healthPercent = (health / maxHealth) * 100

                    for _, v in pairs(host:getStatusEffects()) do
                        if v.name == "effect.minecraft.wither" then
                            return "gray"
                        elseif v.name == "effect.minecraft.poison" then
                            return "dark_green"
                        end
                    end

                    if player:getFrozenTicks() > 0 then
                        return "aqua"
                    end

                    if health > maxHealth then
                        return "#FFD700"
                    end

                    if health > maxHealth then
                        return "#FFD700"
                    end

                    return "#" ..
                        vectors.rgbToHex(healthGradient
                            [math.clamp(math.round(healthPercent), 1, 100)] /
                            255)
                end)(),
            },
            { text = " / ",                                       color = "gray" },
            { text = tostring(math.round(player:getMaxHealth())), color = "red" },
        })):pos(vec((size.x / 2) - 50, size.y - 40, 0) * -1):alignment("CENTER"):setBackground(true)
            :setBackgroundColor(0, 0, 0, 0.5)
    else
        if not player:getVehicle().getMaxHealth or not player:getVehicle().getHealth then
            bypassHealth = true
            goto health
        end

        UI:newText("SideHealth"):text(toJson({
            { text = "Health", color = "red" },
            { text = ": ",     color = "gray" },
            {
                text = tostring(math.round(player:getHealth() + player:getAbsorptionAmount())),
                color = (function()
                    local health = player:getHealth() + player:getAbsorptionAmount()
                    local maxHealth = player:getMaxHealth()
                    local healthPercent = (health / maxHealth) * 100

                    for _, v in pairs(host:getStatusEffects()) do
                        if v.name == "effect.minecraft.wither" then
                            return "gray"
                        elseif v.name == "effect.minecraft.poison" then
                            return "dark_green"
                        end
                    end

                    if player:getFrozenTicks() > 0 then
                        return "aqua"
                    end

                    if health > maxHealth then
                        return "#FFD700"
                    end

                    if health > maxHealth then
                        return "#FFD700"
                    end

                    return "#" ..
                        vectors.rgbToHex(healthGradient
                            [math.clamp(math.round(healthPercent), 1, 100)] /
                            255)
                end)(),
            },
            { text = " / ",                                       color = "gray" },
            { text = tostring(math.round(player:getMaxHealth())), color = "red" },
        })):pos(vec((size.x / 2) - 175, size.y - 15, 0) * -1):alignment("CENTER"):setBackground(true)
            :setBackgroundColor(0, 0, 0, 0.5)

        UI:newText("Health"):text(toJson({ { text = "Health", color = "#D2691E" },
            { text = ": ",     color = "gray" },
            {
                text = tostring(math.round(player:getVehicle():getHealth() +
                    player:getAbsorptionAmount())),
                color = (function()
                    local health = player:getHealth() + player:getAbsorptionAmount()
                    local maxHealth = player:getMaxHealth()
                    local healthPercent = (health / maxHealth) * 100

                    if player:getVehicle():getFrozenTicks() > 0 then
                        return "aqua"
                    end

                    return "#" ..
                        vectors.rgbToHex(healthGradient
                            [math.clamp(math.round(healthPercent), 1, 100)] /
                            255)
                end)(),
            },
            { text = " / ",                                                    color = "gray" },
            { text = tostring(math.round(player:getVehicle():getMaxHealth())), color = "#D2691E" },
        })):pos(vec((size.x / 2) - 50, size.y - 40, 0) * -1):alignment("CENTER"):setBackground(true)
            :setBackgroundColor(0, 0, 0, 0.5)
    end

    UI:newText("Armor"):text(toJson({
        { text = "Armor", color = "white" },
        { text = ": ",    color = "gray" },
        {
            text = tostring(math.round(player:getArmor())),
            color = (function()
                local armor = player:getArmor()
                local armorPercent = (armor / 20) * 100
                -- if player:getExhaustion() > 1 then log(player:getExhaustion()) end
                return "#" ..
                    vectors.rgbToHex(healthGradient[math.clamp(math.round(armorPercent), 1, 100)] /
                        255)
            end)(),
        },
        { text = " / ", color = "gray" },
        { text = "20",  color = "white" },
    })):pos(vec((size.x / 2) - 50, size.y - 52, 0) * -1):alignment("CENTER"):setBackground(true)
        :setBackgroundColor(0, 0, 0, 0.5)

    UI:newText("XP"):text(toJson({
        { text = "XP",                                                              color = "green" },
        { text = " - ",                                                             color = "gray" },
        { text = tostring(math.round(player:getExperienceProgress() * 100)) .. "%", color = "#" .. vectors.rgbToHex(healthGradient[math.clamp(math.round(player:getExperienceProgress() * 100), 1, 100)] / 255) },
        { text = " - ",                                                             color = "gray" },
        { text = "Level ",                                                          color = "green" },
        { text = tostring(math.round(player:getExperienceLevel())),                 color = "green" },
    })):pos(vec((size.x / 2) + 50, size.y - 64, 0) * -1):alignment("CENTER"):setBackground(true)
        :setBackgroundColor(0, 0, 0, 0.5)

    UI:newText("Gamemode"):text(toJson({
        { text = "GM",                                                                    color = "green" },
        { text = ": ",                                                                    color = "gray" },
        { text = player:getGamemode():gsub("%w*", string.lower):gsub("^.", string.upper), color = ((player:getGamemode() == "CREATIVE" and "green") or "red") },
    })):pos(vec((size.x / 2) - 50, size.y - 64, 0) * -1):alignment("CENTER"):setBackground(true)
        :setBackgroundColor(0, 0, 0, 0.5)

    UI:newText("Hunger"):text(toJson({
        { text = "Hunger", color = "#7B3F00" },
        { text = ": ",     color = "gray" },
        {
            text = tostring(math.round(player:getFood())),
            color = (function()
                local hunger = player:getFood()
                local hungerPercent = (hunger / 20) * 100

                for _, v in pairs(host:getStatusEffects()) do
                    if v.name == "effect.minecraft.hunger" then
                        return "dark_green"
                    end
                end

                return "#" ..
                    vectors.rgbToHex(healthGradient[math.clamp(math.round(hungerPercent), 1, 100)] /
                        255)
            end)(),
        },
        { text = " / ",                                       color = "gray" },
        { text = tostring(math.round(player:getMaxHealth())), color = "#7B3F00" },
    })):pos(vec((size.x / 2) + 50, size.y - 40, 0) * -1):alignment("CENTER"):setBackground(true)
        :setBackgroundColor(0, 0, 0, 0.5)

    UI:newText("Saturation"):text(toJson({
        { text = "Saturation", color = "#FFD700" },
        { text = ": ",         color = "gray" },
        {
            text = tostring(math.round(player:getSaturation())),
            color = (function()
                local saturation = player:getSaturation()
                local saturationPercent = (saturation / 20) * 100

                for _, v in pairs(host:getStatusEffects()) do
                    if v.name == "effect.minecraft.hunger" then
                        return "dark_green"
                    end
                end

                return "#" ..
                    vectors.rgbToHex(healthGradient
                        [math.clamp(math.round(saturationPercent), 1, 100)] /
                        255)
            end)(),
        },
        { text = " / ",                                       color = "gray" },
        { text = tostring(math.round(player:getMaxHealth())), color = "#FFD700" },
    })):pos(vec((size.x / 2) + 50, size.y - 52, 0) * -1):alignment("CENTER"):setBackground(true)
        :setBackgroundColor(0, 0, 0, 0.5)

    if enableTracking then
        UI:newText("Tracking"):text(toJson(track(delta))):pos(vec(50, 30, -10000) * -1):light(15)
            :setBackgroundColor(0, 0, 0, 0.5)
    else
        UI:newText("Tracking")
    end

    UI:newText("Air"):text(toJson({
        { text = "Air", color = "aqua" },
        { text = ": ",  color = "gray" },
        {
            text = tostring(math.round(math.clamp(player:getNbt().Air, 0, math.huge))),
            color = (function()
                local air = player:getNbt().Air
                local airPercent = (air / player:getMaxAir()) * 100

                for _, v in pairs(host:getStatusEffects()) do
                    if v.name == "effect.minecraft.water_breathing" then
                        return "aqua"
                    end
                end

                return "#" ..
                    vectors.rgbToHex(healthGradient[math.clamp(math.round(airPercent), 1, 100)] / 255)
            end)(),
        },
        { text = " / ",                                    color = "gray" },
        { text = tostring(math.round(player:getMaxAir())), color = "aqua" },
    })):pos(vec((size.x / 2), size.y - 76, 0) * -1):alignment("CENTER"):setBackground(true)
        :setBackgroundColor(0, 0, 0, 0.5):setVisible(player:isInWater())
end
