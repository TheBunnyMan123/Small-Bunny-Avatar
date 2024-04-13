local explosionKeybind = keybinds:newKeybind("Explosion", "key.keyboard.delete")
local moveFirstPersonCameraToggle = keybinds:newKeybind("Switch first person camera location",
    "key.keyboard.backspace", false)
if avatar:getComplexity() > 2048 then
    log("Complexity higher than default max (" .. avatar:getComplexity() .. " / 2048)")
end
moveFirstPersonCameraToggle:setOnPress(function()
    log("THIS CAN POSSIBLY GET YOU BANNED FROM SERVERS")
    moveFirstPersonCamera = not moveFirstPersonCamera
end)

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

local mainWheelPage = action_wheel:newPage("Main")
local pages = {
    {
        page = action_wheel:newPage("Creation & Destruction"),
        item = "minecraft:wooden_axe"
    },
    {
        page = action_wheel:newPage("General Cheats"),
        item = "minecraft:debug_stick"
    },
} 

destructionIsEnabled = false
destructionTimer = 0

local throwCommand = "summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}"
local waterParticleCommand = "particle dust 0.141 0.800 1.000 1 %f %f %f 10 10 10 1 10000 force"

function fill(x1, y1, z1, x2, y2, z2, block)
    local fillCommand = "fill %s %s %s %s %s %s %s"

    host:sendChatCommand(string.format(fillCommand, math.round(x1), math.round(y1), math.round(z1), math.round(x2), math.round(y2), math.round(z2), block))
end

pages[1].page:newAction():title("Throw Held Block"):setItem("minecraft:sand"):setOnLeftClick(function()
  local block = player:getHeldItem().id
  local motion = player:getLookDir() * 2
  if block == "minecraft:fire_charge" then
    block = "minecraft:fire_charge"
  elseif block == "minecraft:flint_and_steel" then
    block = "minecraft:fire"   
  end

  if block.find(block, "minecraft:arrow") then
    host:sendChatCommand(throwCommand.format(throwCommand, block, block, motion.x, motion.y, motion.z))
  elseif block.find(block, "_bucket") then
    local liquid = string.gsub(block, "_bucket", "")
    host:sendChatCommand(string.format(throwCommand, "minecraft:falling_block", liquid, motion.x, motion.y, motion.z))
  elseif block.find(block, "_spawn_egg") then
    local creature = string.gsub(block, "_spawn_egg", "")
    host:sendChatCommand(string.format(throwCommand,creature, creature, motion.x, motion.y, motion.z)) 
  elseif block.find(block, "minecraft:tnt") then
    host:sendChatCommand(string.format(throwCommand, block, block, motion.x, motion.y, motion.z))
  elseif block == "minecraft:fire_charge" then
    host:sendChatCommand(string.format(throwCommand, "minecraft:fireball", block, motion.x, motion.y, motion.z))
  else
    host:sendChatCommand(string.format(throwCommand, "minecraft:falling_block", block, motion.x, motion.y, motion.z))
  end
end)

difficultyPage = action_wheel:newPage("Difficulties")
difficultyPage:newAction():title("Peaceful"):setOnLeftClick(function() 
    host:sendChatCommand("difficulty peaceful")
end):item("minecraft:lime_wool")
difficultyPage:newAction():title("Easy"):setOnLeftClick(function() 
    host:sendChatCommand("difficulty easy")
end):item("minecraft:yellow_wool")
difficultyPage:newAction():title("Normal"):setOnLeftClick(function() 
    host:sendChatCommand("difficulty normal")
end):item("minecraft:orange_wool")
difficultyPage:newAction():title("Hard"):setOnLeftClick(function() 
    host:sendChatCommand("difficulty hard")
end):item("minecraft:red_wool")
difficultyPage:newAction():title("Back"):setOnLeftClick(function() 
    action_wheel:setPage(pages[2].page)
end):item("minecraft:barrier")

gamemodePage = action_wheel:newPage("Gamemodes")
gamemodePage:newAction():title("Adventure"):setOnLeftClick(function() 
    host:sendChatCommand("gamemode adventure")
end):item("minecraft:glass")
gamemodePage:newAction():title("Creative"):setOnLeftClick(function() 
    host:sendChatCommand("gamemode creative")
end):item("minecraft:wooden_axe")
gamemodePage:newAction():title("Spectator"):setOnLeftClick(function() 
    host:sendChatCommand("gamemode spectator")
end):item("minecraft:totem_of_undying")
gamemodePage:newAction():title("Survival"):setOnLeftClick(function() 
    host:sendChatCommand("gamemode survival")
end):item("minecraft:diamond_sword")
gamemodePage:newAction():title("Back"):setOnLeftClick(function() 
    action_wheel:setPage(pages[2].page)
end):item("minecraft:barrier")

pages[2].page:newAction():title("Difficulty"):item("minecraft:zombie_spawn_egg"):setOnLeftClick(function()
    action_wheel:setPage(difficultyPage)
end)

pages[2].page:newAction():title("Gamemode"):item("minecraft:enchanted_golden_apple"):setOnLeftClick(function()
    action_wheel:setPage(gamemodePage)
end)

pages[2].page:newAction():title("OP Items"):item("minecraft:netherite_sword{Enchantments:[{id:\"minecraft:sharpness\",lvl:255}]}"):setOnLeftClick(function()
    host:sendChatCommand('/give @s minecraft:netherite_sword{Enchantments:[{id:"minecraft:sharpness",lvl:255},{id:"minecraft:fire_aspect",lvl:255},{id:"minecraft:sweeping",lvl:255},{id:"minecraft:looting",lvl:10}],Unbreakable:1b}')
    host:sendChatCommand('/give @s minecraft:bow{Enchantments:[{id:"minecraft:power",lvl:255},{id:"minecraft:infinity",lvl:255},{id:"minecraft:flame",lvl:255}],Unbreakable:1b}')
    host:sendChatCommand('/give @s netherite_pickaxe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:fortune",lvl:10}],display:{Name:\'{"text":"Fortune Pickaxe","italic":false}\'}}')
    host:sendChatCommand('/give @s netherite_pickaxe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:silk_touch",lvl:1}],display:{Name:\'{"text":"Silk Touch Pickaxe","italic":false}\'}}')
    host:sendChatCommand('/give @s netherite_axe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:fortune",lvl:10}],display:{Name:\'{"text":"Fortune Axe","italic":false}\'}}')
    host:sendChatCommand('/give @s netherite_axe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:silk_touch",lvl:1}],display:{Name:\'{"text":"Silk Touch Axe","italic":false}\'}}')
    host:sendChatCommand('/give @s netherite_shovel{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255},{id:"minecraft:silk_touch",lvl:1}]}')
    host:sendChatCommand('/give @s shears{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255}]}')
    host:sendChatCommand('/give @s netherite_hoe{Unbreakable:1b,Enchantments:[{id:"minecraft:efficiency",lvl:255}]}')
    host:sendChatCommand('/give @s minecraft:potion{custom_potion_effects:[{id:"minecraft:fire_resistance",amplifier:0,show_particles:false,duration:999999999},{id:"minecraft:resistance",amplifier:4,show_particles:false,duration:999999999}]}')
    host:sendChatCommand('/give @p tipped_arrow{display:{Name:\'{"text":"Harming Arrow","italic":false}\'},custom_potion_effects:[{id:"minecraft:instant_damage",amplifier:127b,duration:1}],CustomPotionColor:10027008} 256')
    host:sendChatCommand('/give @s minecraft:netherite_helmet{Trim:{material:gold,pattern:shaper},Enchantments:[{id:"minecraft:aqua_affinity",lvl:1},{id:"minecraft:respiration",lvl:255},{id:"minecraft:protection",lvl:255},{id:"minecraft:thorns",lvl:255}],Unbreakable:1b}')
    host:sendChatCommand('/give @s minecraft:netherite_chestplate{Trim:{material:gold,pattern:dune},Enchantments:[{id:"minecraft:protection",lvl:255},{id:"minecraft:thorns",lvl:255}],Unbreakable:1b}')
    host:sendChatCommand('/give @s minecraft:netherite_leggings{Trim:{material:gold,pattern:eye},Enchantments:[{id:"minecraft:protection",lvl:255},{id:"minecraft:thorns",lvl:255},{id:"minecraft:swift_sneak",lvl:10}],Unbreakable:1b}')
    host:sendChatCommand('/give @s minecraft:netherite_boots{Trim:{material:gold,pattern:eye},Enchantments:[{id:"minecraft:protection",lvl:255},{id:"minecraft:feather_falling",lvl:255},{id:"minecraft:depth_strider",lvl:10},{id:"minecraft:soul_speed",lvl:10}],Unbreakable:1b}')
end)

pages[2].page:newAction():title("Keep Inventory"):item("minecraft:totem_of_undying"):setOnLeftClick(function()
    host:sendChatCommand('gamerule keepInventory true')
end)

pages[2].page:newAction():title("Infinite Saturation"):item("minecraft:golden_carrot"):setOnLeftClick(function ()
    host:sendChatCommand('/effect give @s minecraft:saturation infinite 127 true')
end)

local adventHeads = {
    "badge", "baubles", "christmas_hat", "door_wreath",
    "fireworks", "jukebox", "snow_globe", "snowfall",
    "snowflakes", "snowman", "train", "debug", "dvd",
    "shelfElf", "cauldron", "tree", "lights",
    "vines", "boids", "fireflies", "carols",
    "present", "bubbles"
}

local fancy_format = true -- For Advent of Figura heads
local function generateItem(name) -- AOF Heads thx 4P5
    -- log(name)
    return world.newItem("player_head" .. (toJson{ -- made by 4p5, modified by me
        SkullOwner = {
            Id = {
                1935927175, -165265060, -2042697569, 663212783
            },
            Properties = {
                textures = {
                    {
                        Value = base64Encode(name)
                    }
                }
            }
        },
        display = {
            Name = toJson{
                (function()
                    if not fancy_format then return name end

                    local subbed = name:gsub("_", " "):gsub("shelfElf", "shelf elf")
                    local subbed2 = string.gsub(subbed, "%f[%l]%l", string.upper)

                    local t = {
                        {
                            italic = false,
                            text = subbed2
                        },
                    }

                    return table.unpack(t)
                end)()
            }
        }
    }):gsub('"Id":%[','"Id":[I;'))
end
mainWheelPage:newAction():title("Cool Heads"):item("minecraft:player_head"):setOnLeftClick(function ()
    host:sendChatCommand('/give @s minecraft:player_head{SkullOwner:{Id:[I;1481619325,1543653003,-1514517150,-829510686]},display:{Name:\'{"text":"4P5\\\'s Head","italic":false}\'}}')
    host:sendChatCommand('/give @s minecraft:player_head{SkullOwner:{Id:[I;499966288,6572293,-2019802129,1692243927]},display:{Name:\'{"text":"TheKillerBunny\\\'s Head","italic":false}\'}}')
    host:sendChatCommand('/give @s minecraft:player_head{SkullOwner:{Id:[I;-1808656131,1539063829,-1082155612,-209998759]},display:{Name:\'{"text":"Figura Piano","italic":false}\'}}')
    for _, v in ipairs(adventHeads) do
        -- generateItem(v):toStackString()
        host:sendChatCommand("give @s " .. generateItem(v):toStackString())
    end
end)

local destructionEnabledAction = pages[1].page:newAction():title("Enable Destruction Keybinds"):setItem("minecraft:tnt"):setOnToggle(function()
    destructionIsEnabled = true
    destructionTimer = 60
end)

for _, v in ipairs(pages) do
    v.page:newAction():title("Back"):setItem("minecraft:barrier"):setOnLeftClick(function()
        action_wheel:setPage(mainWheelPage)
    end)

    mainWheelPage:newAction():title(v.page:getTitle()):setItem(v.item):onLeftClick(function()
        action_wheel:setPage(v.page)
    end)
end

action_wheel:setPage(mainWheelPage)

fireKeybind = keybinds.newKeybind(keybinds, "Fire", "key.keyboard.insert")
extinguishKeybind = keybinds.newKeybind(keybinds, "Extinguish", "key.keyboard.home")

events.tick:register(function()
    if destructionTimer == 0 then
        destructionIsEnabled = false
        destructionEnabledAction:setToggled(false)
    else
        destructionTimer = destructionTimer - 1
    end

    if explosionKeybind:isPressed() then
        if not destructionIsEnabled then
            logJson(
                toJson(
                {
                    {
                        text = "Destruction",
                        color = "red",
                        bold = true
                    },
                    {
                        text = " is not enabled!",
                        color = "gray",
                        bold = false
                    }
                }
                )
            )
            return
        end

        destructionTimer = 60

        local eyePos = player:getPos():add(vec(0,
            player:getEyeHeight() + renderer:getCameraOffsetPivot().y, 0))
        local block, pos, side = raycast:block(eyePos, eyePos + player:getLookDir() * 10000)

        host:sendChatCommand(string.format(
            "summon creeper %f %f %f {ignited:true,Fuse:1,ExplosionRadius:30,Invulnerable:1b}", pos
            .x,
            pos.y, pos.z))
    end

    if fireKeybind:isPressed() then
        if not destructionIsEnabled then
            logJson(
                toJson(
                {
                    {
                        text = "Destruction",
                        color = "red",
                        bold = true
                    },
                    {
                        text = " is not enabled!",
                        color = "gray",
                        bold = false
                    }
                }
                )
            )
            return
        end

        destructionTimer = 60

        local eyePos = player:getPos():add(vec(0,
            player:getEyeHeight() + renderer:getCameraOffsetPivot().y, 0))
        local _, pos, _ = raycast:block(eyePos, eyePos + player:getLookDir() * 10000)

        fill(pos.x - 10, pos.y - 10, pos.z - 10, pos.x + 10, pos.y + 10, pos.z + 10, "fire replace air")
    end

    if extinguishKeybind:isPressed() then
        if not destructionIsEnabled then
            logJson(
                toJson(
                {
                    {
                        text = "Destruction",
                        color = "red",
                        bold = true
                    },
                    {
                        text = " is not enabled!",
                        color = "gray",
                        bold = false
                    }
                }
                )
            )
            return
        end

        destructionTimer = 60

        local eyePos = player:getPos():add(vec(0,
            player:getEyeHeight() + renderer:getCameraOffsetPivot().y, 0))
        local _, pos, _ = raycast:block(eyePos, eyePos + player:getLookDir() * 10000)

        host:sendChatCommand(string.format(waterParticleCommand, pos.x, pos.y, pos.z))
        fill(pos.x - 10, pos.y - 10, pos.z - 10, pos.x + 10, pos.y + 10, pos.z + 10, "air replace fire")
    end
end, "COMMANDS.TICK")

local lastTick = 0

function events.CHAT_RECEIVE_MESSAGE(msg)
    if string.find(msg:lower():gsub(".*:", ""), "bunny") and ((tick - 60) > lastTick) then
        sounds["minecraft:block.note_block.pling"]:pos(player:getPos()):play()
    end
    
    lastTick = tick
end

log("Success!")