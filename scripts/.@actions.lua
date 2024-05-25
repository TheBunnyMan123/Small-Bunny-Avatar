moveCamera = false

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
        page = action_wheel:newPage("shaders"),
        item = "minecraft:red_mushroom",
    },
}

local shaders = {
    "notch",
    "fxaa",
    "art",
    "bumpy",
    "blobs2",
    "pencil",
    "color_convolve",
    "deconverge",
    "flip",
    "invert",
    "ntsc",
    "outline",
    "phosphor",
    "scan_pincushion",
    "sobel",
    "bits",
    "desaturate",
    "green",
    "blur",
    "wobble",
    "blobs",
    "antialias",
    "creeper",
    "spider",
}

local iter = 1
for k, v in ipairs(shaders) do
    iter = iter + 1
    pages[2].page:newAction(k+1):title(v):setOnLeftClick(function()
        disableBlur = true
        renderer:setPostEffect(v)
    end):color((iter % 2 ~= 0 and vec(0.5, 0.5, 0.5) or vec(1, 1, 1)))
end
log(iter)
while iter % 8 ~= 0 do
    pages[2].page:newAction():hoverColor(0, 0, 0)
    iter = iter + 1
end

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
_log(player:getLookDir())
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
                host:sendChatCommand(("summon %s ~ ~1 ~ {power:[%f, %f, %f]}")
                    :format("minecraft:fireball", player:getLookDir():div(5, 5, 5):unpack()))
            else
                host:sendChatCommand(("summon %s ~ ~1 ~ {Fuse:40,BlockState:{Name:\"%s\"},Motion:[%f, %f, %f]}")
                    :format("minecraft:falling_block", block, motion:unpack()))
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

iter = 0
for i, v in pairs(creationDestructionActions) do
    iter = iter + 1
    pages[1].page:newAction(i + 1):title(v.title):setItem(v.item):setOnLeftClick(v.func):color((iter % 2 ~= 0 and vec(0.5, 0.5, 0.5) or vec(1, 1, 1)))
end
while iter % 8 ~= 0 do
    pages[1].page:newAction():hoverColor(0, 0, 0)
    iter = iter + 1
end

mainWheelPage:setAction(-1, autoanims:color(1, 1, 1))

local heads = {
    {
        name = "TheKillerBunny\\\'s Head",
        id = { 499966288, 6572293, -2019802129, 1692243927 },
        textures = {
            "blahaj",
        },
    },
    {
        name = "Advent Of Figura",
        id = { 1935927175, -165265060, -2042697569, 663212783 },
        textures = {
            -- "badge", "baubles", "christmas_hat", "door_wreath",
            -- "fireworks", "jukebox", "snow_globe", "snowfall",
            -- "snowflakes", "snowman", "train", "debug", "dvd",
            -- "shelfElf", "cauldron", "tree", "lights",
            -- "vines", --[["boids", "fireflies",]] "carols",
            -- "present", "bubbles",
        },
    },
    {
        name = "4P5\\\'s Head",
        id = { 1481619325, 1543653003, -1514517150, -829510686 },
        textures = {
            -- "turret",
            -- "point_defense",
            -- "railgun",
            -- "disco",
            -- "sentry",
            -- "voidspace",
            -- "forcefield",
            -- "music_display",
            "tripwire;ff0000",
            "tripwire;00ff00",
            "tripwire;0000ff",
            "lamp",
            "mirrors;splitter",
            "mirrors;mirror",
            "mirrors;lens",
            "mirrors;prism",
            "mini_blocks;smooth_stone", --end rods redirect laser
            "mirrors;aligner",
            "mirrors;redirector",
        },
    },
    {
        name = "Figura Piano",
        id = { -1808656131, 1539063829, -1082155612, -209998759 },
        textures = {},
    },
}

local function generateItem(id, name)               -- AOF Heads thx 4P5
    -- log(name)
    return world.newItem("player_head" .. (toJson { -- made by 4p5, modified by me
        SkullOwner = {
            Id = {
                id[1], id[2], id[3], id[4],
            },
            Properties = {
                textures = {
                    {
                        Value = base64.encode(name),
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
        host:sendChatCommand("give @s minecraft:player_head{SkullOwner:{Id:[I;" ..
        v.id[1] ..
        "," ..
        v.id[2] ..
        "," ..
        v.id[3] ..
        "," .. v.id[4] .. "]},display:{Name:\'{\"text\":\"" .. v.name .. "\",\"italic\":false}\'}}")
        for _, w in ipairs(v.textures) do
            host:sendChatCommand("give @s " ..
                generateItem(v.id, w):toStackString())
        end
    end
end):color(0.5, 0.5, 0.5)

mainWheelPage:newAction():title("Move Camera"):item(getHeadModel("camera")):setOnToggle(function(
    state)
    moveCamera = state
end):color(1, 1, 1)

mainWheelPage:newAction():title("Reset Entities"):item(getHeadModel("drone")):setOnLeftClick(function()
    for _, v --[[@as LibEntity.Entity]] in pairs(CustomEntities) do
        v.model:setPos(player:getPos() * 16)
        v:setPos(player:getPos())
    end
end):color(0.5, 0.5, 0.5)

mainWheelPage:newAction():title("Disable Sun Blur"):item("minecraft:shroomlight"):setOnToggle(function(
    state)
    disableBlur = state
end):color(1, 1, 1)

iter = 5
for _, v in ipairs(pages) do
    iter = iter + 1
    v.page:setAction(1,
        action_wheel:newAction():title("§lBack§r"):setItem("minecraft:arrow"):setOnLeftClick(function()
            action_wheel:setPage(mainWheelPage)
        end):color(0.8, 0.8, 0.8))

    mainWheelPage:newAction():title(v.page:getTitle()):setItem(v.item):onLeftClick(function()
        action_wheel:setPage(v.page)
    end):color((iter % 2 ~= 0 and vec(1, 1, 1) or vec(0.5, 0.5, 0.5)))
end
while iter % 8 ~= 0 do
    mainWheelPage:newAction():hoverColor(0, 0, 0)
    iter = iter + 1
end

action_wheel:setPage(mainWheelPage)

local oldCamPos = renderer:getCameraOffsetPivot()

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
    if moveCamera then
        local head = models.model.root.Head
        -- renderer:setOffsetCameraPivot(calcMatrix(head):translate(0,-1.7,0):apply(head:getPivot()) / 16)
        --renderer:setEyeOffset(renderer:getCameraPivot())
        local piv = calcMatrix(head):apply(head:getPivot()) / 16 + player:getPos(delta) +
        vec(0, head:getScale().y / 2 / 16, 0)
        local offsetPiv = piv - (player:getPos(delta) + vec(0, 1.7, 0))

        renderer:setOffsetCameraPivot(offsetPiv)
        renderer:setEyeOffset(offsetPiv)
    else
        renderer:setOffsetCameraPivot(nil)
    end
end, "CAMERA.RENDER")
