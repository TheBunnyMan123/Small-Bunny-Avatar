--hide vanilla models
vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

--- 4P5 lol
function getEntities(a, b)
    local e = {}

    raycast:entity(a, b, function(hit)
        e[#e + 1] = hit
        return false
    end)

    return pairs(e)
end

--libs
local anims = require("libs/JimmyAnims")
local fakeNameplate = require("libs/nameplate")
anims(animations.model)

-- vars
moveFirstPersonCamera = false
swingDelay = 0
nameplateHead =
'["",{"text":"${badges}"},{"text":"\n"},{"text":":rabbit: "},{"text":"Bunny","color":"#40E0D0"},{"text":" :rabbit:"}'
nameplateOther =
'["",{"text":":rabbit: "},{"text":"Bunny","color":"#40E0D0"},{"text":" :rabbit: "}, {"text":"${badges}"}]'
nameplate_extra = ""
alreadyAfk = false
task = nil
blockBelowCache = {}

-- keybinds
local ringToggle = keybinds:newKeybind("Toggle health ring", "key.keyboard.right.bracket", false)

function pings.ringToggleRemote(x)
    models.model.root.RightArm.Upper.Lower.Ring:setVisible(x)
end

function events.entity_init()
    if file.allowed(file) then
        local files = file.list(file, "")
        if files then
            for _, v in pairs(files) do
                -- log(v)
                if string.gmatch(v, "") then
                    log("Loading: " .. tostring(v))
                    -- log(files)
                    local script = loadstring(file.readString(file, v))
                    log(script()())
                end
            end
        else
            log("Please run setup.sh in the avatar folder")
        end
    end

    ringToggle:setOnPress(function()
        models.model.RightArmFP.Upper5.Lower5.Ring2:setVisible(not models.model.root.RightArm.Upper
        .Lower.Ring:getVisible())
        pings.ringToggleRemote(not models.model.root.RightArm.Upper.Lower.Ring:getVisible())
    end)
end

-- customization
function events.render(_, context)
    local fp = (context == "FIRST_PERSON")
    models.model.RightArmFP:setVisible(fp)
    models.model.root.RightArm:setVisible(not fp)
    models.model.root.Head.HelmetPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.Head.HelmetItemPivot:setScale(0.75, 0.75, 0.75)
    models.model.root.Body.ChestplatePivot:setScale(0.7, 0.7, 0.7)
    models.model.root.RightArm.Upper.RightShoulderPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.LeftArm.Upper4.LeftShoulderPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.RightArm.Upper.Lower.RightItemPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.LeftArm.Upper4.Lower4.LeftItemPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.Body.LeggingsPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.LeftLeg.Upper2.LeftLeggingPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.RightLeg.Upper3.RightLeggingPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.LeftLeg.Upper2.Lower2.LeftBootPivot:setScale(0.7, 0.7, 0.7)
    models.model.root.RightLeg.Upper3.Lower3.RightBootPivot:setScale(0.7, 0.7, 0.7)

    -- camera
    if renderer:isFirstPerson() then
        renderer:setOffsetCameraPivot(moveFirstPersonCamera and vec(0, -0.5, 0) or vec(0, 0, 0))
        renderer:setEyeOffset(moveFirstPersonCamera and vec(0, -0.5, 0) or vec(0, 0, 0))
    else
        renderer:setOffsetCameraPivot(0, -0.5, 0)
        renderer:setEyeOffset(0, -0.5, 0)
    end

    --   if host:isHost() then
    --   for _, v in getEntities(player:getPos() - vec(5, 5, 5), player:getPos() + vec(5, 5, 5)) do
    --     -- log(v)
    --     if v.getUUID(v) == "1dcce150-0064-4905-879c-43ef64dd97d7" then
    --         return
    --     end

    --     local x, y, z = v:getPos():unpack()
    --     local x2, y2, z2 = player:getPos():unpack()
    --     log((x2 - x) * -1 .. " " .. (y2 - y) * -1 .. " " .. (z2 - z) * -1)

    --     host:sendChatCommand("tp " .. v.getUUID(v) .. " " .. string.format("%f %f %f", ((x2 - x) * -1) + x, ((y2 - y) * -1) + y, ((z2 - z) * -1) + z))
    -- end
    -- end
end

local tick = 0
function events.tick()
    --ring
    local health = player:getHealth() / player:getMaxHealth()
    models.model.root.RightArm.Upper.Lower.Ring.HealthRingHealthIndicatorReal:setColor(1 - health,
        health, 0.05)
    models.model.RightArmFP.Upper5.Lower5.Ring2.HealthRingHealthIndicatorReal2:setColor(1 - health,
        health, 0.05)

    if swingDelay > 0 then
        swingDelay = swingDelay - 1
    end
end
