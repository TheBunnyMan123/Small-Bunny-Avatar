--hide vanilla models
vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

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

local figway

function events.entity_init()
    nameplate.ALL:setText(nameplateOther)
    nameplate.ENTITY:setText(toJson(
        {
            {
                text = "${badges}"
            },
            {
                text = "\n:rabbit: "
            },
            {
                text = "Bunny",
                color = "aqua"
            },
            {
                text = " :rabbit:",
                color = "white"
            }
        }
    ))
    nameplate.ENTITY:setPos(models.model.root.Head.nameplate:getTruePos() - vec(0, 0.5, 0))
end
local tick = 0
local oldTick = -1
-- customization
local frame = 0
function events.render(_, context)
    models.model.root:setScale(0.7)

    local jetpackOn = ((player:getGamemode() == "CREATIVE") or (player:getItem(5).id == "minecraft:elytra"))
    models.model.root.Body.Jetpack:setVisible(jetpackOn)

    local smokeOn = (not player:isOnGround() and jetpackOn and context ~= "FIRST_PERSON")

    if smokeOn then
        local smokePivotLeft = models.model.root.Body.Jetpack.SmokePivotLeft
        local smokePivotRight = models.model.root.Body.Jetpack.SmokePivotRight
        local plrRot = player:getLookDir()
        local fireTimeOff = player:getVelocity():length()

        particles:newParticle("minecraft:smoke", smokePivotLeft:partToWorldMatrix():apply(0,0,0),vec(0,-0.2,0)):setScale(0.25)
        particles:newParticle("minecraft:smoke", smokePivotRight:partToWorldMatrix():apply(0,0,0),vec(0,-0.2,0)):setScale(0.25)
        particles:newParticle("minecraft:flame", smokePivotLeft:partToWorldMatrix():apply(0,0,0), vec(0,-0.2,0)):setLifetime(4 - fireTimeOff):setScale(0.5)
        particles:newParticle("minecraft:flame", smokePivotRight:partToWorldMatrix():apply(0,0,0), vec(0,-0.2,0)):setLifetime(4 - fireTimeOff):setScale(0.5)
    end
    -- camera
    -- if renderer:isFirstPerson() then
    --     renderer:setOffsetCameraPivot(moveFirstPersonCamera and vec(0, -0.5, 0) or vec(0, 0, 0))
    --     renderer:setEyeOffset(moveFirstPersonCamera and vec(0, -0.5, 0) or vec(0, 0, 0))
    -- else
    --     renderer:setOffsetCameraPivot(0, -0.5, 0)
    --     renderer:setEyeOffset(0, -0.5, 0)
    -- end

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

function events.tick()
    tick = tick + 1
    if swingDelay > 0 then
        swingDelay = swingDelay - 1
    end
end
