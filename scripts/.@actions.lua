moveCamera = false

local base64 =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b = base64

-- encoding

local function base64Encode(data)
    return ((data:gsub(".", function(x)
        ---@diagnostic disable-next-line: unused-local
        local r, b = "", x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r;
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if (#x < 6) then return "" end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

function fill(x1, y1, z1, x2, y2, z2, block)
    local fillCommand = "fill %s %s %s %s %s %s %s"

    host:sendChatCommand(string.format(fillCommand, math.round(x1), math.round(y1), math.round(z1),
        math.round(x2), math.round(y2), math.round(z2), block))
end

local mainWheelPage = action_wheel:newPage("Main")
local pages = {
    {
        page = action_wheel:newPage("Creation & Destruction"),
        item = "minecraft:wooden_axe",
    },
    {
        page = action_wheel:newPage("General Cheats"),
        item = "minecraft:debug_stick",
    },
}

local creationDestructionActions = {
    {
        title = "Throw Held Block",
        item = "minecraft:sand",
        func = function()
            local block = player:getHeldItem().id
            local motion = player:getLookDir() * 2
            if block == "minecraft:fire_charge" then
                block = "minecraft:fire_charge"
            elseif block == "minecraft:flint_and_steel" then
                block = "minecraft:fire"
            end

            if block.find(block, "minecraft:arrow") then
                host:sendChatCommand(("summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}")
                :format(block, block, motion.x, motion.y, motion.z))
            elseif block.find(block, "_bucket") then
                local liquid = string.gsub(block, "_bucket", "")
                host:sendChatCommand(("summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}")
                :format("minecraft:falling_block", liquid, motion.x, motion.y, motion.z))
            elseif block.find(block, "_spawn_egg") then
                local creature = string.gsub(block, "_spawn_egg", "")
                host:sendChatCommand(("summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}")
                :format(creature, creature, motion.x, motion.y, motion.z))
            elseif block.find(block, "minecraft:tnt") then
                host:sendChatCommand(("summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}")
                :format(block, block, motion.x, motion.y, motion.z))
            elseif block == "minecraft:fire_charge" then
                host:sendChatCommand(("summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}")
                :format("minecraft:fireball", block, motion.x, motion.y, motion.z))
            else
                host:sendChatCommand(("summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}")
                :format("minecraft:falling_block", block, motion.x, motion.y, motion.z))
            end
        end,
    },
    {
        title = "Enable Destruction Keybinds",
        item = "minecraft:tnt",
        func = function()
            destructionIsEnabled = true
            destructionTimer = 60
        end,
    },
}

local iter = 0
for i, v in pairs(creationDestructionActions) do
    iter = iter + 1
    pages[1].page:newAction(i + 1):title(v.title):setItem(v.item):setOnLeftClick(v.func):color(0.2,
        0.2, 0.2)
end
while iter % 8 ~= 0 do
    pages[1].page:newAction():hoverColor(0, 0, 0)
    iter = iter + 1
end

local difficultyActions = {
    {
        difficulty = "peaceful",
        item = "minecraft:lime_wool",
    },
    {
        difficulty = "easy",
        item = "minecraft:yellow_wool",
    },
    {
        difficulty = "normal",
        item = "minecraft:orange_wool",
    },
    {
        difficulty = "hard",
        item = "minecraft:red_wool",
    },
}

iter = 0
difficultyPage = action_wheel:newPage("Difficulties")
for i, v in pairs(difficultyActions) do
    iter = iter + 1
    difficultyPage:newAction(i + 1):title(v.difficulty:gsub("^.", string.upper)):item(v.item)
        :setOnLeftClick(function()
            host:sendChatCommand("difficulty " .. v.difficulty)
        end):color(0.2, 0.2, 0.2)
end
difficultyPage:newAction(1):title("§lBack§r"):setOnLeftClick(function()
    action_wheel:setPage(pages[2].page)
end):item("minecraft:arrow"):color(0.8, 0.8, 0.8)
while iter % 8 ~= 0 do
    difficultyPage:newAction():hoverColor(0, 0, 0)
    iter = iter + 1
end

local gamemodeActions = {
    {
        gamemode = "adventure",
        item = "minecraft:barrier",
    },
    {
        gamemode = "creative",
        item = "minecraft:totem_of_undying",
    },
    {
        gamemode = "survival",
        item = "minecraft:diamond_sword",
    },
    {
        gamemode = "spectator",
        item = "minecraft:glass",
    },
}

iter = 0
gamemodePage = action_wheel:newPage("Gamemodes")
gamemodePage:newAction(1):title("§lBack§r"):setOnLeftClick(function()
    action_wheel:setPage(pages[2].page)
end):item("minecraft:arrow"):color(0.8, 0.8, 0.8)
for i, v in pairs(gamemodeActions) do
    iter = iter + 1
    gamemodePage:newAction(i + 1):title(v.gamemode:gsub("^.", string.upper)):item(v.item)
        :setOnLeftClick(function()
            host:sendChatCommand("difficulty " .. v.difficulty)
        end):color(0.2, 0.2, 0.2)
end
while iter % 8 ~= 0 do
    gamemodePage:newAction():hoverColor(0, 0, 0)
    iter = iter + 1
end

local cheats = {
    {
        title = "Difficulties",
        item = "minecraft:zombie_spawn_egg",
        func = function()
            action_wheel:setPage(difficultyPage)
        end,
    },
    {
        title = "Gamemodes",
        item = "minecraft:enchanted_golden_apple",
        func = function()
            action_wheel:setPage(gamemodePage)
        end,
    },
    {
        title = "OP Items",
        item = "minecraft:netherite_sword{Enchantments:[{id:\"minecraft:sharpness\",lvl:255}]}",
        func = function()
            host:sendChatCommand(
            '/give @s minecraft:netherite_sword{Enchantments:[{id:"minecraft:sharpness",lvl:255},{id:"minecraft:fire_aspect",lvl:255},{id:"minecraft:sweeping",lvl:255},{id:"minecraft:looting",lvl:10}],Unbreakable:1b}')
            host:sendChatCommand(
            '/give @s minecraft:bow{Enchantments:[{id:"minecraft:power",lvl:255},{id:"minecraft:infinity",lvl:255},{id:"minecraft:flame",lvl:255}],Unbreakable:1b}')
            host:sendChatCommand(
            '/give @s netherite_pickaxe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:fortune",lvl:10}],display:{Name:\'{"text":"Fortune Pickaxe","italic":false}\'}}')
            host:sendChatCommand(
            '/give @s netherite_pickaxe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:silk_touch",lvl:1}],display:{Name:\'{"text":"Silk Touch Pickaxe","italic":false}\'}}')
            host:sendChatCommand(
            '/give @s netherite_axe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:fortune",lvl:10}],display:{Name:\'{"text":"Fortune Axe","italic":false}\'}}')
            host:sendChatCommand(
            '/give @s netherite_axe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:silk_touch",lvl:1}],display:{Name:\'{"text":"Silk Touch Axe","italic":false}\'}}')
            host:sendChatCommand(
            '/give @s netherite_shovel{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:silk_touch",lvl:1}]}')
            host:sendChatCommand(
            '/give @s shears{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255}]}')
            host:sendChatCommand(
            '/give @s netherite_hoe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255}]}')
            host:sendChatCommand(
            '/give @p tipped_arrow{display:{Name:\'{"text":"Harming Arrow","italic":false}\'},custom_potion_effects:[{id:"minecraft:instant_damage",amplifier:127b,duration:1}],CustomPotionColor:10027008} 256')
            host:sendChatCommand(
            '/give @s minecraft:netherite_helmet{Trim:{material:gold,pattern:shaper},Enchantments:[{id:"minecraft:aqua_affinity",lvl:1},{id:"minecraft:respiration",lvl:255},{id:"minecraft:protection",lvl:255},{id:"minecraft:thorns",lvl:255}],Unbreakable:1b}')
            host:sendChatCommand(
            '/give @s minecraft:netherite_chestplate{Trim:{material:gold,pattern:dune},Enchantments:[{id:"minecraft:protection",lvl:255},{id:"minecraft:thorns",lvl:255}],Unbreakable:1b}')
            host:sendChatCommand(
            '/give @s minecraft:netherite_leggings{Trim:{material:gold,pattern:eye},Enchantments:[{id:"minecraft:protection",lvl:255},{id:"minecraft:thorns",lvl:255},{id:"minecraft:swift_sneak",lvl:10}],Unbreakable:1b}')
            host:sendChatCommand(
            '/give @s minecraft:netherite_boots{Trim:{material:gold,pattern:eye},Enchantments:[{id:"minecraft:protection",lvl:255},{id:"minecraft:feather_falling",lvl:255},{id:"minecraft:depth_strider",lvl:10},{id:"minecraft:soul_speed",lvl:10}],Unbreakable:1b}')
        end,
    },
    {
        title = "Keep Inventory",
        item = "minecraft:totem_of_undying",
        func = function()
            host:sendChatCommand("gamerule keepInventory true")
        end,
    },
    {
        title = "OP Effects",
        item = "minecraft:potion",
        func = function()
            host:sendChatCommand("effect give @s saturation infinite 127 true")
            host:sendChatCommand("effect give @s resistance infinite 127 true")
            host:sendChatCommand("effect give @s fire_resistance infinite 127 true")
        end,
    },
}

iter = 0
for i, v in ipairs(cheats) do
    iter = iter + 1
    pages[2].page:newAction(i + 1):title(v.title):item(v.item):setOnLeftClick(v.func):color(0.2, 0.2,
        0.2)
end
while iter % 8 ~= 0 do
    pages[2].page:newAction():hoverColor(0, 0, 0)
    iter = iter + 1
end

mainWheelPage:setAction(-1, autoanims:color(0.2, 0.2, 0.2))

local heads = {
    {
        name = "TheKillerBunny\\\'s Head",
        id = {499966288,6572293,-2019802129,1692243927},
        textures = {
            "blahaj"
        },
    },
    {
        name = "Advent Of Figura",
        id = { 1935927175, -165265060, -2042697569, 663212783 },
        textures = {
            "badge", "baubles", "christmas_hat", "door_wreath",
            "fireworks", "jukebox", "snow_globe", "snowfall",
            "snowflakes", "snowman", "train", "debug", "dvd",
            "shelfElf", "cauldron", "tree", "lights",
            "vines", "boids", "fireflies", "carols",
            "present", "bubbles",
        },
    },
    {
        name = "4P5\\\'s Head",
        id = { 1481619325, 1543653003, -1514517150, -829510686 },
        textures = {
            "turret",
            "point_defense",
            "railgun",
            "disco",
            "sentry",
            "forcefield",
            "music_display",
        },
    },
    {
        name = "Figura Piano",
        id = {-1808656131,1539063829,-1082155612,-209998759},
        textures = {}
    }
}

local function generateItem(id, name)              -- AOF Heads thx 4P5
    -- log(name)
    return world.newItem("player_head" .. (toJson { -- made by 4p5, modified by me
        SkullOwner = {
            Id = {
                id[1], id[2], id[3], id[4],
            },
            Properties = {
                textures = {
                    {
                        Value = base64Encode(name),
                    },
                },
            },
        },
        display = {
            Name = toJson {
                (function()
                    local subbed = name:gsub("_", " "):gsub("shelfElf", "shelf elf")
                    local subbed2 = string.gsub(subbed, "%f[%l]%l", string.upper)

                    local t = {
                        {
                            italic = false,
                            text = subbed2,
                        },
                    }

                    return table.unpack(t)
                end)(),
            },
        },
    }):gsub('"Id":%[', '"Id":[I;'))
end

mainWheelPage:newAction():title("Cool Heads"):item("minecraft:player_head"):setOnLeftClick(function()
    for _, v in ipairs(heads) do
        host:sendChatCommand("give @s minecraft:player_head{SkullOwner:{Id:[I;" .. v.id[1] .. "," .. v.id[2] .. "," .. v.id[3] .. "," .. v.id[4] .. "]},display:{Name:\'{\"text\":\"" .. v.name .. "\",\"italic\":false}\'}}")
        for _, w in ipairs(v.textures) do
            host:sendChatCommand("give @s " ..
        generateItem(v.id, w):toStackString())
        end
    end
end):color(0.2, 0.2, 0.2)

mainWheelPage:newAction():title("Move Camera"):item("minecraft:glass"):setOnToggle(function(state)
    moveCamera = state
end):color(0.2, 0.2, 0.2)

mainWheelPage:newAction():title("Player Tracking"):item("minecraft:barrier"):setOnToggle(function (state)
    enableTracking = state
end):color(0.2, 0.2, 0.2)

iter = 2
for _, v in ipairs(pages) do
    iter = iter + 1
    v.page:setAction(1,
        action_wheel:newAction():title("§lBack§r"):setItem("minecraft:arrow"):setOnLeftClick(function()
            action_wheel:setPage(mainWheelPage)
        end):color(0.8, 0.8, 0.8))

    mainWheelPage:newAction():title(v.page:getTitle()):setItem(v.item):onLeftClick(function()
        action_wheel:setPage(v.page)
    end):color(0.2, 0.2, 0.2)
end
while iter % 8 ~= 0 do
    mainWheelPage:newAction():hoverColor(0, 0, 0)
    iter = iter + 1
end

action_wheel:setPage(mainWheelPage)

local oldCamPos = renderer:getCameraOffsetPivot()

local function calcMatrix(p)
    return p and (calcMatrix(p:getParent()) * p:getPositionMatrix()) or matrices.mat4()
end

local function calcPos(p)
    if p:getParent() then
        if p:getParent():getTruePos() == vec(0, 0, 0) then
            return vec(1, 1, 1)
        end
    end
    return p and (calcPos(p:getParent()) * p:getTruePos()) or vectors.vec3()
end

local function badPose()
    local pose = player:getPose()

    return player:getBoundingBox().y <= 1
end

events.render:register(function(delta, context, matrix)
    if moveCamera and player:getPose() == "SITTING" then
        renderer:setOffsetCameraPivot(vec(0, -0.3, 0))
        renderer:setEyeOffset(vec(0, -0.3, 0))
    elseif moveCamera and not badPose() then
        renderer:setOffsetCameraPivot(vec(0, -0.5, 0))
        renderer:setEyeOffset(vec(0, -0.5, 0))
    else
        renderer:setOffsetCameraPivot(nil)
    end
end, "CAMERA.RENDER")
