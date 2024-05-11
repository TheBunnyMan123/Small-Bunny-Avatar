drone = models.drone.World

local droneEntity = LibEntity.new("drone", vec(0, 0, 0), {
    (vec(5.5, 0, 5.5) * -1) / 16,
    vec(5.5, 6, 5.5) / 16,
})

function setParentType(model, type)
    model:setParentType(type)
    for k, v in pairs(model:getChildren()) do
        setParentType(v, type)
        model:getChildren()[k]:setParentType(type)
    end
end

function pings.dronepos(pos)
    droneEntity:setAI("DRONE", drone, tostring(pos.x) .. "," .. tostring(pos.y) .. "," .. tostring(pos.z))

    customTarget = pos
end

function pings.setDroneFollow(e)
    droneEntity:setAI("DRONE", drone, e)
end

droneEntity:setAI("DRONE", drone, "TheKillerBunny")
