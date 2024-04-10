---@diagnostic disable: undefined-global, redefined-local
local base64 =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" -- You will need this for encoding/decoding

local function splitByChunk(text, chunkSize)
    local s = {}
    for i = 1, #text, chunkSize do
        s[#s + 1] = text:sub(i, i + chunkSize - 1)
    end
    return s
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

-- encoding

local function base64Encode(data)
    return ((data:gsub(".", function(x)
        ---@diagnostic disable-next-line: unused-local
        local r, base64 = "", x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r;
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if (#x < 6) then return "" end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

-- decoding
local function base64Decode(data)
    data = string.gsub(data, "[^" .. base64 .. "=]", "")
    return (data:gsub(".", function(x)
        if (x == "=") then return "" end
        local r, f = "", (base64:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r;
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if (#x ~= 8) then return "" end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

function splitByChunk(text, chunkSize)
    local s = {}
    for i = 1, #text, chunkSize do
        table.insert(s, text:sub(i, i + chunkSize - 1))
    end

    return s
end

local tick = 0
function events.tick()
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

function events.skull_render(delta, block, item, entity, mode)
    if not block then
        if models.skull.Skull.text then
            models.skull.Skull.text:setVisible(false)
        end
        models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
        models.skull.Skull:setPos(0, -19, 0):setScale(1.55).Table:setVisible(false)
        models.skull.Skull.TheHead.Head:setVisible(false)
        models.skull.Skull["Ear 1"]:setVisible(true)
        models.skull.Skull["Ear 2"]:setVisible(true)
        return
    end
    models.skull.Skull.TheHead.Head:setVisible(true)
    if block == nil then
        return
    end
    models.skull.Skull.TheHead.FloorPainting:setVisible(false)
    models.skull.Skull.TheHead.Head:setVisible(true)
    models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
    models.skull.Skull["Ear 1"]:setVisible(true)
    models.skull.Skull["Ear 2"]:setVisible(true)
    if block:getProperties() == nil then
        return
    end
    if block.id == "minecraft:player_wall_head" then
        models.skull.Skull.TheHead.Head:setVisible(true)
        models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
        models.skull.Skull:setPos(0, -10.1, 1.8):setScale(1).Table:setVisible(false)
    else
        local is_table = block:getProperties().rotation % 4 == 0

        models.skull.Skull
            :setPos(is_table and vec(0, 0, 0) or vec(0, -12, 0)):setScale(1)
            .Table:setVisible(is_table)
    end

    -- Only run main code section if enough instructions and complexity are given to skull
    if (avatar:getMaxComplexity() >= 10000) and (avatar:getMaxRenderCount() >= 150000) and (avatar:getMaxTickCount() >= 2000) then
        local blockBelow = world.getBlockState(block:getPos() - vec(0, 1, 0))

        if blockBelow.id == "minecraft:player_head" then
            -- Hide main head and show projector
            models.skull.Skull.text:setVisible(true)
            models.skull.Skull:setPos(vec(0, -12 - 8, 0)):setScale(1):setVisible(true).Table
                :setVisible(false)
            models.skull.Skull.TheHead.Head:setVisible(false)
            models.skull.Skull.TheHead.CommandBlockProjector:setVisible(true)
            models.skull.Skull["Ear 1"]:setVisible(false)
            models.skull.Skull["Ear 2"]:setVisible(false)

            -- Set variables
            local owner = blockBelow:getEntityData().SkullOwner
            local tempText

            -- Set string to display skull owner's name, or if name is not available, UUID, with texture if available
            if owner.Name then
                tempText = owner.Name .. "\'s Skull"
                if owner.Properties then
                    if owner.Properties.textures then
                        if parseJson(base64Decode(owner.Properties.textures[1].Value)) then
                            tempText = owner.Name ..
                                "\'s Skull\n" ..
                                base64Decode(owner.Properties.textures[1].Value)
                        else
                            tempText = owner.Name ..
                                "\'s Skull\n" .. base64Decode(owner.Properties.textures[1].Value)
                        end
                    end
                end
            elseif owner.Id then
                tempText = client.intUUIDToString(owner.Id[1], owner.Id[2], owner.Id[3], owner.Id[4]) ..
                    "\'s Skull"
                if owner.Properties then
                    if owner.Properties.textures then
                        if parseJson(base64Decode(owner.Properties.textures[1].Value)) then
                            tempText = client.intUUIDToString(owner.Id[1], owner.Id[2], owner.Id[3],
                                    owner.Id[4]) ..
                                "\'s Skull" ..
                                "\n" ..
                                base64Decode(owner.Properties.textures[1].Value)
                        else
                            tempText = client.intUUIDToString(owner.Id[1], owner.Id[2], owner.Id[3],
                                    owner.Id[4]) ..
                                "\'s Skull" ..
                                "\n" .. base64Decode(owner.Properties.textures[1].Value)
                        end
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
            models.skull.Skull.text:newText("text")
                :setPos(vec(0, 25 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
                :setText(tempText)
                :setScale(0.3)
                :setAlignment("LEFT")
                :setShadow(true)
                :setWrap(true)
            models.skull.Skull.text:newText("text2")
                :setPos(vec(0, 25 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
                :setText(tempText)
                :setScale(0.3)
                :setAlignment("LEFT")
                :setShadow(true)
                :setWrap(true)
                :setRot(0, 180, 0) -- Flip along y axis to be viewed from other side
        elseif string.find(blockBelow.id, "_sign") then
            -- Hide main head and show projector
            models.skull.Skull.text:setVisible(true)
            models.skull.Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table
                :setVisible(false)
            models.skull.Skull.TheHead.Head:setVisible(false)
            models.skull.Skull.TheHead.CommandBlockProjector:setVisible(true)
            models.skull.Skull["Ear 1"]:setVisible(false)
            models.skull.Skull["Ear 2"]:setVisible(false)

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
            local text1 = models.skull.Skull.text:newText("text")
                :setPos(vec(0, 15 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
                :setText(tempText)
                :setScale(0.3)
                :setAlignment("LEFT")
                :setShadow(true)
                :setWrap(true)
                :setAlignment("CENTER")
            local text2 = models.skull.Skull.text:newText("text2")
                :setPos(vec(0, 15 + (count * 3), 0)) -- Raise position by 25 + (3 times count)
                :setText(tempText)
                :setScale(0.3)
                :setAlignment("LEFT")
                :setShadow(true)
                :setWrap(true)
                :setRot(0, 180, 0) -- Flip along y axis to be viewed from other side
                :setAlignment("CENTER")
        elseif blockBelow.id == "minecraft:smooth_quartz" or blockBelow.id == "minecraft:smooth_quartz_slab" then
            models.skull.Skull:setPos(vec(0, 0, 0))
            models.skull.Skull.TheHead.Head:setVisible(false)
            models.skull.Skull["Ear 1"]:setVisible(false)
            models.skull.Skull["Ear 2"]:setVisible(false)
            models.skull.Skull.Table:setVisible(false)
            models.skull.Skull.TheHead.FloorPainting:setVisible(true)

            local picIndex = {
                "MyselfPicture",
                "GNPicture",
                "AuriaPictureMermaid",
                "MinecraftTerrain"
            }

            for i = #picIndex, 1, -1 do
                if tick % (40 * i) == 0 then
                    models.skull.Skull.TheHead.FloorPainting.Picture:setPrimaryTexture("CUSTOM", textures["skull." .. picIndex[i]])
                    goto done
                end
            end
            ::done::
        else
            if models.skull.Skull.text then
                models.skull.Skull.text:setVisible(false)
            end
        end
    else
        -- If not enough instructions and complexity are given to skull, display text requesting higher permissions

        -- Hide projector and show main head
        models.skull.Skull.text:setVisible(true)
        models.skull.Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table:setVisible(false)
        models.skull.Skull.TheHead.Head:setVisible(true)
        models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
        models.skull.Skull["Ear 1"]:setVisible(true)
        models.skull.Skull["Ear 2"]:setVisible(true)
        local text2 = models.skull.Skull.text:newText("text2")

        -- Display text
        local txt =
        "This skull requires a helluva\n lot of render instructions,\n please raise my permissions!"
        models.skull.Skull.text:newText("text")
            :setPos(vec(0, 30 + (3 * 5), 0))
            :setText(txt)
            :setScale(0.5)
            :setAlignment("CENTER")
            :setShadow(true)
            :setWrap(true)
        models.skull.Skull.text:newText("text2")
            :setPos(vec(0, 30 + (3 * 5), 0))
            :setText(txt)
            :setScale(0.5)
            :setAlignment("CENTER")
            :setShadow(true)
            :setWrap(true)
            :setRot(0, 180, 0)
    end
end
