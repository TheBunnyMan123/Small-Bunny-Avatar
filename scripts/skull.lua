---@diagnostic disable: undefined-global, redefined-local, param-type-mismatch
 -- You will need this for encoding/decoding
tick = 0
oldTick = -1
local function splitByChunk(text, chunkSize)
    local s = {}
    for i = 1, #text, chunkSize do
        s[#s + 1] = text:sub(i, i + chunkSize - 1)
    end
    return s
end

local lines = {}
local GNLineLib = require("GNLineLib") --[[@as GNLineLib]]

local function drawCube(x, y, z, x2, y2, z2)
    local dx, dy, dz = vec(x2, y2, z2):sub(x, y, z):unpack()

    table.insert(lines, GNLineLib:new():setA(x, y, z):setB(x + dx, y, z):setColor(1, 0, 0):setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x + dx, y, z):setB(x + dx, y, z + dz):setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x + dx, y, z + dz):setB(x, y, z + dz):setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x, y, z + dz):setB(x, y, z):setColor(0, 0, 1):setWidth(0.05))

    table.insert(lines, GNLineLib:new():setA(x, y + dy, z):setB(x + dx, y + dy, z):setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x + dx, y + dy, z):setB(x + dx, y + dy, z + dz)
    :setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x + dx, y + dy, z + dz):setB(x, y + dy, z + dz)
    :setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x, y + dy, z + dz):setB(x, y + dy, z):setWidth(0.05))

    table.insert(lines, GNLineLib:new():setA(x, y, z):setB(x, y + dy, z):setColor(0, 1, 0):setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x + dx, y, z):setB(x + dx, y + dy, z):setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x + dx, y, z + dz):setB(x + dx, y + dy, z + dz)
    :setWidth(0.05))
    table.insert(lines, GNLineLib:new():setA(x, y, z + dz):setB(x, y + dy, z + dz):setWidth(0.05))

    return lines
end


local disc = {
    {
        id = "minecraft:music_disc_13",
        name = "C418 - 13",
    },
    {
        id = "minecraft:music_disc_cat",
        name = "C418 - Cat",
    },
    {
        id = "minecraft:music_disc_blocks",
        name = "C418 - Blocks",
    },
    {
        id = "minecraft:music_disc_chirp",
        name = "C418 - Chirp",
    },
    {
        id = "minecraft:music_disc_far",
        name = "C418 - Far",
    },
    {
        id = "minecraft:music_disc_mall",
        name = "C418 - Mall",
    },
    {
        id = "minecraft:music_disc_mellohi",
        name = "C418 - Mellohi",
    },
    {
        id = "minecraft:music_disc_stal",
        name = "C418 - Stal",
    },
    {
        id = "minecraft:music_disc_strad",
        name = "C418 - Strad",
    },
    {
        id = "minecraft:music_disc_ward",
        name = "C418 - Ward",
    },
    {
        id = "minecraft:music_disc_11",
        name = "C418 - 11",
    },
    {
        id = "minecraft:music_disc_wait",
        name = "C418 - Wait",
    },
    {
        id = "minecraft:music_disc_otherside",
        name = "Lena Raine - Otherside",
    },
    {
        id = "minecraft:music_disc_relic",
        name = "Aaron Cherof - Relic",
    },
    {
        id = "minecraft:music_disc_5",
        name = "Samuel Åberg - 5",
    },
    {
        id = "minecraft:music_disc_pigstep",
        name = "Lena Raine - Pigstep",
    },
}

function splitByChunk(text, chunkSize)
    local s = {}
    for i = 1, #text, chunkSize do
        table.insert(s, text:sub(i, i + chunkSize - 1))
    end

    return s
end

function events.world_tick()
    oldTick = tick
    tick = tick + 1
    -- log(tick)
end

function getTextFromSign(textArray)
    local messages = textArray.messages

    local msg = ""

    count = 4

    for i, v in ipairs(messages) do
        count = count + 1

        msg = msg .. i .. ": \n"

        for _, w in ipairs(splitByChunk(v, 64)) do
            count = count + 1

            msg = msg .. w .. "\n"
        end

        msg = msg .. "\n"
        count = count + 1
    end

    return msg, count
end

local funcs = {
    {
        exact = true,
        block = "minecraft:player_head",
        func = function(delta, blockBelow)
            -- Hide main head and show projector
            models["💀"].Skull.text:setVisible(true)
            models["💀"].Skull:setPos(vec(0, -12 - 8, 0)):setScale(1):setVisible(true).Table
                :setVisible(false)
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(true)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)

            -- Set variables
            local owner = blockBelow:getEntityData().SkullOwner
            local tempText

            -- Set string to display skull owner's name, or if name is not available, UUID, with texture if available
            if owner.Name then
                tempText = owner.Name .. "\'s Skull"
                if owner.Properties then
                    if owner.Properties.textures then
                        -- if parseJson(base64.decode(owner.Properties.textures[1].Value)) then
                        --     tempText = owner.Name ..
                        --         "\'s Skull\n" ..
                        --         base64.decode(owner.Properties.textures[1].Value)
                        -- else
                        tempText = owner.Name ..
                            "\'s Skull\n" .. base64.decode(owner.Properties.textures[1].Value)
                        -- end
                    end
                end
            elseif owner.Id then
                tempText = client.intUUIDToString(owner.Id[1], owner.Id[2], owner.Id[3], owner.Id[4]) ..
                    "\'s Skull"
                if owner.Properties then
                    if owner.Properties.textures then
                        -- if parseJson(base64.decode(owner.Properties.textures[1].Value)) then
                        --     tempText = client.intUUIDToString(owner.Id[1], owner.Id[2], owner.Id[3],
                        --             owner.Id[4]) ..
                        --         "\'s Skull" ..
                        --         "\n" ..
                        --         base64.decode(owner.Properties.textures[1].Value)
                        -- else
                        tempText = client.intUUIDToString(owner.Id[1], owner.Id[2], owner.Id[3],
                                owner.Id[4]) ..
                            "\'s Skull" ..
                            "\n" .. base64.decode(owner.Properties.textures[1].Value)
                        -- end
                    end
                end
            end

            -- If tempText is not set, then stop running to prevent error
            if not tempText then
                return
            end

            -- Calculate how many times a line break occurs
            local count = 0
            local check
            for _, v in pairs(splitByChunk(tempText, 1)) do
                if v == "\n" then
                    count = count + 1
                end
            end

            -- Display text
            models["💀"].Skull.text:newText("text")
                :setPos(vec(0, 25 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
                :setText(tempText)
                :setScale(0.3)
                :setAlignment("LEFT")
                :setShadow(true)
                :setWrap(true)
            models["💀"].Skull.text:newText("text2")
                :setPos(vec(0, 25 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
                :setText(tempText)
                :setScale(0.3)
                :setAlignment("LEFT")
                :setShadow(true)
                :setWrap(true)
                :setRot(0, 180, 0) -- Flip along y axis to be viewed from other side
        end,
    },
    {
        exact = false,
        block = "_sign",
        func = function(delta, blockBelow)
            -- Hide main head and show projector
            models["💀"].Skull.text:setVisible(true)
            models["💀"].Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table
                :setVisible(false)
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(true)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)

            local tempText = ""
            local properties = blockBelow.getEntityData(blockBelow)

            local waxed = false
            if properties.is_waxed == 1 then
                waxed = true
            end

            local front_text, count1 = getTextFromSign(properties.front_text)
            local back_text, count2 = getTextFromSign(properties.back_text)

            local count = count1 + count2

            tempText = "Waxed: "
            if waxed then
                tempText = tempText .. "true"
            else
                tempText = tempText .. "false"
            end

            tempText = tempText ..
                "\nFront Text: \n\n" .. front_text .. "\nBack Text: \n\n" .. back_text

            -- Display text
            local text1 = models["💀"].Skull.text:newText("text")
                :setPos(vec(0, 15 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
                :setText(tempText)
                :setScale(0.3)
                :setShadow(true)
                :setWrap(true)
                :setAlignment("CENTER")
            local text2 = models["💀"].Skull.text:newText("text2")
                :setPos(vec(0, 15 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
                :setText(tempText)
                :setScale(0.3)
                :setShadow(true)
                :setWrap(true)
                :setRot(0, 180, 0) -- Flip along y axis to be viewed from other side
                :setAlignment("CENTER")
        end,
    },
    {
        exact = false,
        block = "minecraft:smooth_quartz",
        func = function(delta, blockBelow)
            models["💀"].Skull:setPos(vec(0, 0, 0))
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)
            models["💀"].Skull.Table:setVisible(false)
            models["💀"].Skull.TheHead.FloorPainting:setVisible(true)

            local picIndex = {
                "MyselfPicture",
                "GNPicture",
                "AuriaPictureMermaid",
                "MinecraftTerrain",
            }

            for i = #picIndex, 1, -1 do
                if tick % (40 * i) == 0 then
                    models["💀"].Skull.TheHead.FloorPainting.Picture:setPrimaryTexture("CUSTOM",
                        getTexture(picIndex[i]))
                    goto done
                end
            end
            ::done::
        end,
    },
    {
        exact = true,
        block = "minecraft:prismarine",
        texture = "blahaj",
        func = function(delta, blockBelow)
            models.blahaj.Skull:setVisible(true)
            models["💀"].Skull:setPos(vec(0, 0, 0))
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)
            models["💀"].Skull.Table:setVisible(false)
            models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
            models["💀"].Skull.text:setVisible(false)

            models.blahaj.Skull:setRot(
                0, math.lerp(oldTick * 3, tick * 3, delta), 0
            )

            local facecamera = models["💀"].Skull
                :setPos(vec(0, 15, 0))
                :setPivot(0, 0, 0)
                :newPart("BlahajText")
                :setVisible(true)
                :setParentType("CAMERA")

            facecamera:newText("text")
                :setText(toJson({
                    { text = ":blahaj:", color = "white", bold = false },
                    { text = " BLAHAJ ", color = "aqua",  bold = false },
                    { text = ":blahaj:", color = "white", bold = false },
                }))
                :setScale(0.3)
                :setShadow(true)
                :setWrap(true)
                :setAlignment("CENTER")
                :setVisible(true)
                :setRot(0, 0, 0)
        end,
    },
    {
        exact = true,
        block = "minecraft:glass",
        texture = "ESP",
        func = function(delta, blockBelow)
            models.blahaj.Skull:setVisible(false)
            models["💀"].Skull:setPos(vec(0, -12, 0))
            models["💀"].Skull.TheHead.Head:setVisible(true)
            models["💀"].Skull["Ear 1"]:setVisible(true)
            models["💀"].Skull["Ear 2"]:setVisible(true)
            models["💀"].Skull.Table:setVisible(false)
            models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
            models["💀"].Skull.text:setVisible(false)

            local iter = 1

            for _, v in pairs(world:getPlayers()) do
                if v:isLoaded() then
                    iter = iter + 1

                    table.insert(lines, GNLineLib:new()
                        :setA(blockBelow:getPos() + vec(0.5, 1.2, 0.5))
                        :setB(v:getPos(delta) + vec(0, 1, 0))
                        :setColor(vec(1, 0.2, 0))
                        :setWidth(0.1))
                end
            end

            for _, v in pairs(LibEntity.getEntities()) do
                table.insert(lines, GNLineLib:new()
                    :setA(blockBelow:getPos() + vec(0.5, 1.2, 0.5))
                    :setB(v:getPos())
                    :setColor(vec(1, 0.2, 0))
                    :setWidth(0.1))

                -- log(v:getHitbox())

                local hbox1 = v:getHitbox()[1]:copy()
                local hbox2 = v:getHitbox()[2]:copy()
                local hbox1final = hbox1:add(v:getPos())
                local hbox2final = hbox2:add(v:getPos())
                -- log(hbox1final:floor():div(16, 16, 16), hbox2final:floor(), v:getPos():floor())
                drawCube(hbox1final.x, hbox1final.y, hbox1final.z, hbox2final.x,
                    hbox2final.y, hbox2final.z)
            end
        end,
    },
    {
        exact = true,
        block = "",
        texture = "plush",
        func = function(delta, blockBelow)
            models.blahaj.Skull:setVisible(false)
            models["💀"].Skull:setPos(vec(0, -12, 0))
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)
            models["💀"].Skull.Table:setVisible(false)
            models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
            models["💀"].Skull.text:setVisible(false)
            models.plush.Skull:scale(0.8 * 0.6):setVisible(true)
        end,
    },
}

local dronePart = deepCopy(models.drone)

local nonBlockScripts = {
    {
        texture = "camera",
        func = function()
            models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
            models.blahaj.Skull:setVisible(false)
            models["💀"].Skull.text:setVisible(false)
            models["💀"].Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table:setVisible(false)
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(false)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)
            models.camera.Skull:setPos(0, 0, 0):setParentType("Skull"):setVisible(true)
            models.drone_static.Skull:setPos(0, 0.5, 0):setParentType("Skull"):setVisible(false):setScale(1.5)
        end
    },
    {
        texture = "drone",
        func = function()
            models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
            models.blahaj.Skull:setVisible(false)
            models["💀"].Skull.text:setVisible(false)
            models["💀"].Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table:setVisible(false)
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(false)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)
            models.camera.Skull:setPos(0, 0, 0):setParentType("Skull"):setVisible(false):setScale(0.75)
            models.drone_static.Skull:setPos(0, 3, 0):setParentType("Skull"):setVisible(true):setScale(1.5)
        end
    },
    {
        texture = "wand",
        func = function()
            models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
            models.blahaj.Skull:setVisible(false)
            models["💀"].Skull.text:setVisible(false)
            models["💀"].Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table:setVisible(false)
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(false)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)
            models.camera.Skull:setPos(0, 0, 0):setParentType("Skull"):setVisible(false):setScale(0.75)
            models.drone_static.Skull:setPos(0, 3, 0):setParentType("Skull"):setVisible(false):setScale(1.5)
            models.wand.Skull:setVisible(true):setRot(0, renderer:isFirstPerson() and 0 or 315, 0)
                :scale(renderer:isFirstPerson() and 0.7 or 1.5)
                :setPivot(renderer:isFirstPerson() and vec(0, 0, 0) or vec(2.33333, 10, 4))
        end
    },
    {
        texture = "plush",
        func = function(delta, blockBelow)
            models.blahaj.Skull:setVisible(false)
            models["💀"].Skull:setPos(vec(0, -12, 0))
            models["💀"].Skull.TheHead.Head:setVisible(false)
            models["💀"].Skull["Ear 1"]:setVisible(false)
            models["💀"].Skull["Ear 2"]:setVisible(false)
            models["💀"].Skull.Table:setVisible(false)
            models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
            models["💀"].Skull.text:setVisible(false)
            models.plush.Skull:scale(0.8 * 0.6):setVisible(true)
        end,
    },
}

function events.skull_render(delta, block, item, entity, mode)
    models.plush.Skull:scale(0.8 * 0.6):setVisible(false)
    models.wand.Skull:setVisible(false)
    if models["💀"].Skull.BlahajText then
        models["💀"].Skull.BlahajText:remove()
    end

    models.camera.Skull:setVisible(false)
    models.drone_static.Skull:setVisible(false)

    if not block then
        if models["💀"].Skull.text then
            models["💀"].Skull.text:setVisible(false)
        end
        if models["💀"].Skull.text then
            models["💀"].Skull.text:setVisible(false)
        end
        models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
        models.blahaj.Skull:setVisible(false)
        models["💀"].Skull.text:setVisible(false)
        models["💀"].Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table:setVisible(false)
        models["💀"].Skull.TheHead.Head:setVisible(true)
        models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(false)
        models["💀"].Skull["Ear 1"]:setVisible(true)
        models["💀"].Skull["Ear 2"]:setVisible(true)

        if item then
                if type(item.tag.SkullOwner) == "table" then
                    if item.tag.SkullOwner.Properties then
                        if item.tag.SkullOwner.Properties.textures then
                            for _, v in pairs(nonBlockScripts) do
                                if v.texture == base64.decode(item.tag.SkullOwner.Properties.textures[1].Value) then
                                    v.func()
                                end
                            end
                        end
                    end
                end
        end

        return
    end

    for k, v in pairs(lines) do
        v:free()
        lines[k] = nil
    end

    if not minimal then
        models["💀"].Skull.TheHead.Head:setVisible(true)
        if block == nil then
            return
        end

        models["💀"].Skull.TheHead.FloorPainting:setVisible(false)
        models["💀"].Skull.TheHead.Head:setVisible(true)
        models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(false)
        models["💀"].Skull["Ear 1"]:setVisible(true)
        models["💀"].Skull["Ear 2"]:setVisible(true)
        models.blahaj.Skull:setVisible(false)

        if block:getProperties() == nil then
            return
        end
        if block.id == "minecraft:player_wall_head" then
            models["💀"].Skull.TheHead.Head:setVisible(true)
            models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(false)
            models["💀"].Skull:setPos(0, -10.1, 1.8):setScale(1).Table:setVisible(false)
        else
            local is_table = block:getProperties().rotation % 4 == 0

            models["💀"].Skull
                :setPos(is_table and vec(0, 0, 0) or vec(0, -12, 0)):setScale(1)
                .Table:setVisible(is_table)
        end

        -- Only run main code section if enough instructions and complexity are given to skull
        local blockBelow = world.getBlockState(block:getPos() - vec(0, 1, 0))

        for _, v in pairs(funcs) do
            if block:getEntityData() then
                if v.texture and block:getEntityData().SkullOwner.Properties then
                    if block:getEntityData().SkullOwner.Properties.textures then
                        if base64.decode(block:getEntityData().SkullOwner.Properties.textures[1].Value) == v.texture then
                            v.func(delta, blockBelow)
                            return
                        end
                    end
                end
            end

            if (v.exact == true and blockBelow.id == v.block) or (v.exact == false and blockBelow.id:find(v.block)) then
                v.func(delta, blockBelow)
                return
            end
        end

        models["💀"].Skull.text:setVisible(true)
        models["💀"].Skull:setVisible(true)
        models["💀"].Skull.TheHead.Head:setVisible(true)
        models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(false)
        models["💀"].Skull["Ear 1"]:setVisible(true)
        models["💀"].Skull["Ear 2"]:setVisible(true)

        local count = 1

        local tempText =
            "You decapitated me!\nPlace my head on one of the following blocks for something cool to happen." ..
            (function()
                local tempTempText = ""

                for _, v in pairs({
                    {
                        block = "Player Head (floor)",
                        desc = "Displays info about the head",
                    },
                    {
                        block = "Any Sign",
                        desc = "Displays info about the sign",
                    },
                    {
                        block = "Smooth Quartz / Smooth Quartz Slab",
                        desc = "Becomes a picture frame that loops through pictures",
                    },
                    {
                        block = "Prismarine",
                        desc = ":blahaj: SPINNING BLAHAJ :blahaj:",
                    },
                }) do
                    count = count + 1
                    tempTempText = tempTempText .. "\n" .. v.block .. ": " .. v.desc
                end

                return tempTempText
            end)()

        -- Display text
        local text1 = models["💀"].Skull.text:newText("text")
            :setPos(vec(0, 25 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
            :setText(tempText)
            :setScale(0.3)
            :setAlignment("LEFT")
            :setShadow(true)
            :setWrap(true)
            :setAlignment("CENTER")
        local text2 = models["💀"].Skull.text:newText("text2")
            :setPos(vec(0, 25 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
            :setText(tempText)
            :setScale(0.3)
            :setAlignment("LEFT")
            :setShadow(true)
            :setWrap(true)
            :setRot(0, 180, 0) -- Flip along y axis to be viewed from other side
            :setAlignment("CENTER")
    else
        -- If not enough instructions and complexity are given to skull, display text requesting higher permissions

        -- Hide projector and show main head
        models["💀"].Skull.text:setVisible(true)
        models["💀"].Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table:setVisible(false)
        models["💀"].Skull.TheHead.Head:setVisible(true)
        models["💀"].Skull.TheHead.CommandBlockProjector:setVisible(false)
        models["💀"].Skull["Ear 1"]:setVisible(true)
        models["💀"].Skull["Ear 2"]:setVisible(true)
        models.blahaj.Skull:setVisible(false)
        local text2 = models["💀"].Skull.text:newText("text2")

        -- Display text
        local txt =
        "This skull requires a helluva\n lot of render instructions,\n please raise my permissions!"
        models["💀"].Skull.text:newText("text")
            :setPos(vec(0, 30 + (3 * 5), 0))
            :setText(txt)
            :setScale(0.5)
            :setAlignment("CENTER")
            :setShadow(true)
            :setWrap(true)
        models["💀"].Skull.text:newText("text2")
            :setPos(vec(0, 30 + (3 * 5), 0))
            :setText(txt)
            :setScale(0.5)
            :setAlignment("CENTER")
            :setShadow(true)
            :setWrap(true)
            :setRot(0, 180, 0)
    end
end
