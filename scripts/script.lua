--hide vanilla models
vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

-- vars
moveFirstPersonCamera = false
swingDelay = 0
nameplateOther =
'["",{"text":":rabbit: "},{"text":"Bunny","color":"#40E0D0"},{"text":" :rabbit: "}, {"text":"${badges}"}]'
nameplate_extra = ""
alreadyAfk = false
task = nil
blockBelowCache = {}

local tick = 0
local oldTick = -1
-- customization
local frame = 0
function events.render(_, context)
    models.model.root:setScale(0.7)

    local jetpackOn = ((player:getGamemode() == "CREATIVE") or (player:getItem(5).id == "minecraft:elytra"))
    models.model.root.Body.Jetpack:setVisible(jetpackOn)

    local smokeOn = (not player:isOnGround() and jetpackOn and context ~= "FIRST_PERSON")

    if smokeOn and not minimal then
        local smokePivotLeft = models.model.root.Body.Jetpack.SmokePivotLeft
        local smokePivotRight = models.model.root.Body.Jetpack.SmokePivotRight
        local plrRot = player:getLookDir()
        local fireTimeOff = player:getVelocity():length()

        particles:newParticle("minecraft:smoke", smokePivotLeft:partToWorldMatrix():apply(0,0,0),vec(0,-0.2,0)):setScale(0.25)
        particles:newParticle("minecraft:smoke", smokePivotRight:partToWorldMatrix():apply(0,0,0),vec(0,-0.2,0)):setScale(0.25)
        particles:newParticle("minecraft:flame", smokePivotLeft:partToWorldMatrix():apply(0,0,0), vec(0,-0.2,0)):setLifetime(4 - fireTimeOff):setScale(0.5)
        particles:newParticle("minecraft:flame", smokePivotRight:partToWorldMatrix():apply(0,0,0), vec(0,-0.2,0)):setLifetime(4 - fireTimeOff):setScale(0.5)
    end
end

function events.tick()
    tick = tick + 1
    if swingDelay > 0 then
        swingDelay = swingDelay - 1
    end
end

function events.entity_init()
    for _, v in pairs(world:getPlayers()) do
        if v:getName() == "TheKillerBunny" then
            followEntity = v
        end
    end
end