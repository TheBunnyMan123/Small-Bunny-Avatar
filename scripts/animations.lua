invOpen = false
chestBlock = "chest"

function pings.openChest()
    animations.model.chest_open:play()
end

function pings.closeChest()
    animations.model.chest_open:stop()
    animations.model.chest_close:play()
end

function events.tick()
    if player:getGamemode() == "CREATIVE" then
        chestBlock = "ender_chest"
    else
        chestBlock = "chest"
    end

    if client:getDate().month == 12 then
        chestBlock = "chest"
        chestTexture = "christmas"
    elseif chestBlock == "chest" then
        chestTexture = "normal"
    else
        chestTexture = "ender"
    end

    for _, v in pairs(models.model.root.LeftLeg.Chest:getChildren()) do
        v:setPrimaryTexture("RESOURCE", "minecraft:textures/entity/chest/" .. chestTexture .. ".png")
        for _, w in pairs(v:getChildren()) do
            w:setPrimaryTexture("RESOURCE", "minecraft:textures/entity/chest/" .. chestTexture .. ".png")
        end
    end

    if host:isHost() and player:isLoaded() then
        local targetedBlock = player:getTargetedBlock(true, 5).id
        local target = player:getTargetedEntity(5)
        local tagetedEntity = ""
        if target then tagetedEntity = target:getType() end

        if host:isContainerOpen() and not tagetedEntity:find("llama") and not tagetedEntity:find("horse") and not tagetedEntity:find("camel") and not tagetedEntity:find("mule") and not targetedBlock:find("chest") and not targetedBlock:find("hopper") and not targetedBlock:find("barrel") then
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
end