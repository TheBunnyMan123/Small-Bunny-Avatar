invOpen = false

function pings.openChest()
    animations.model.chest_open:play()
end

function pings.closeChest()
    animations.model.chest_open:stop()
    animations.model.chest_close:play()
end

function events.tick()
    local targetedBlock = player:getTargetedBlock(true, 5).id
    local target = player:getTargetedEntity(5)
    local tagetedEntity = ""
    if target then tagetedEntity = target:getType() end

    if host:isContainerOpen() and not tagetedEntity:find("llama") and not tagetedEntity:find("mule") and not targetedBlock:find("chest") and not targetedBlock:find("hopper") and not targetedBlock:find("barrel") then
        if not invOpen then
            pings.openChest()
            invOpen = true
        end
    else
        if invOpen then
            pings.closeChest()
            invOpen = false
        end
    end
end