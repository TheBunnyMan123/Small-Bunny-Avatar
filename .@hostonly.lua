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

local mainWheelPage = action_wheel:newPage("Main")
local pages = {
    {
        page = action_wheel:newPage("Creation & Destruction"),
        item = "minecraft:wooden_axe"
    }
} 

destructionIsEnabled = false
destructionTimer = 0

pages[1].page:newAction():title("Back"):setItem("minecraft:barrier"):setOnLeftClick(function()
    action_wheel:setPage(mainWheelPage)
end)

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


local destructionEnabledAction = pages[1].page:newAction():title("Enable Destruction Keybinds"):setItem("minecraft:tnt"):setOnToggle(function()
    destructionIsEnabled = true
    destructionTimer = 60
end)

for _, v in ipairs(pages) do
    mainWheelPage:newAction():title(v.page:getTitle()):setItem(v.item):onLeftClick(function()
        action_wheel:setPage(v.page)
    end)
end

action_wheel:setPage(mainWheelPage)

fireKeybind = keybinds.newKeybind(keybinds, "Fire", "key.keyboard.insert")
extinguishKeybind = keybinds.newKeybind(keybinds, "Fire", "key.keyboard.home")

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

log("Success!")