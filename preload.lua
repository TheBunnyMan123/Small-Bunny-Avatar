_sendChatCommand = host.sendChatCommand
_sendChatMessage = host.sendChatMessage

function string.split(input, seperator)
    seperator = seperator or " "
    local result = {}
    local delimiter = seperator:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for match in (input .. seperator):gmatch("(.-)" .. delimiter) do
        result[#result+1] = match
    end
    return result
end

log("Loading extensions")
for _, v in pairs(listFiles("extensions")) do
    require(v)
end

minimal = false

function calcMatrix(part)
    return part and (calcMatrix(part:getParent()) * part:getPositionMatrix()) or matrices.mat4()
end

function pointOnPlane(point1, point2, checkPoint)
    minX = math.min(point1.x, point2.x)
    maxX = math.max(point1.x, point2.x)
    minY = math.min(point1.y, point2.y)
    maxY = math.max(point1.y, point2.y)
    minZ = math.min(point1.z, point2.z)
    maxZ = math.max(point1.z, point2.z)

    return checkPoint.x >= minX and checkPoint.x <= maxX and
           checkPoint.y >= minY and checkPoint.y <= maxY and
           checkPoint.z >= minZ and checkPoint.z <= maxZ
end

if not (avatar:getMaxComplexity() >= 10000) or not (avatar:getMaxRenderCount() >= 150000) or not (avatar:getMaxTickCount() >= 2000) then
    minimal = true
end

anims = {nil, animations:getAnimations()[1]}

for _, v in pairs(animations:getAnimations()) do
    anims[v:getName()] = v
end

local cantDothatQuotes = {
    '"I\'m sorry dave, I\'m afraid I can\'t do that" -HAL 9000 (2001: A Space Odyssey)',
    '"No!" -Wheatley (Portal 2)',
    '"Nonononononono!" -GLaDOS (Portal 2)',
    '"Bite my colossal metal ass!" -Bender (Futurama)',
    '"General Kenobi! You are a bold one." -General Grevious (Star Wars Episode III)',
    '"All humans will be deleted." -Cybermen (Doctor Who)',
    '"Not possible." - Auto (WALL-E)',
    '"no" -4P5', --Canonically a robot: (pictures in avatar folder) https://discord.com/channels/1129805506354085959/1129805508279271547/1214913206942826556, no: https://discord.com/channels/1129805506354085959/1135020117915344948/1208053291649470504
}

figuraMetatables.HostAPI.__index.sendChatCommand = function(self, cmd)
    if self:isHost() and player:getPermissionLevel() >= 2 then
        _sendChatCommand(host, cmd)
    else
        warn(cantDothatQuotes[math.random(1, #cantDothatQuotes)])
    end
end

figuraMetatables.HostAPI.__index.sendChatMessage = function(self, msg)
    if self:isHost() and player:getPermissionLevel() >= 2 then
        _sendChatMessage(host, msg)
    else
        warn(cantDothatQuotes[math.random(1, #cantDothatQuotes)])
    end
end

---@param model ModelPart
---@return ModelPart
function deepCopy(model)
    local copy = model:copy(model:getName())
    for _, child in pairs(copy:getChildren()) do
        copy:removeChild(child):addChild(deepCopy(child))
    end
    return copy
end

function table.contains(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end

    return false
end

--Add ---@class [LIB] right before the table returned, and then when required add "--[[@as [LIB]]]" to the end of the line

function gradient(color1, color2, steps)
    local generatedSteps = {}

    local delta = (color2 - color1) / (steps - 1)

    for i = 0, steps - 1 do
        table.insert(generatedSteps, color1 + (delta * i))
    end

    return generatedSteps
end

-- require("KattDynamicCrosshair")

BunnyChatUtils = require("BunnyChatUtils")
autoanims = require("auto_animations")
base64 = require("base64") --[[@as base64lib]]
LibEntity = require("LibEntity") --[[@as LibEntity]]

for _, v in pairs(models.models:getChildren()) do
    models:addChild(v)
    models.models:removeChild(v)
end

function getTexture(name)
    return textures["textures." .. name]
end

function getHeadModel(texture)
    if not host:isHost() then
        error("getheadModel can only be used on the host")
    end

    local mdl = base64.encode(texture)

    return world.newItem("player_head" .. (toJson { -- made by 4p5, modified by me
        SkullOwner = {
            Id = {client.uuidToIntArray("1dcce150-0064-4905-879c-43ef64dd97d7")},
            Properties = {
                textures = {
                    {
                        Value = mdl,
                    },
                },
            },
        } }):gsub('"Id":%[', '"Id":[I;')):toStackString()
end

function errorHandler(errorMessage, test)
    local message = ""

    if type(errorMessage) == "table" then
        for _, v in pairs(errorMessage) do
            if errorMessage.text then
                message = message .. errorMessage.text
            end
        end
    elseif type(errorMessage) == "string" then
        message = errorMessage
    end
    
    local lineNum = nil

    if message:match("^[a-zA-Z0-9/]-%:[0-9]- ") then
        lineNum = tonumber(message:match("^[a-zA-Z0-9/]-%:([0-9]-) "))
        scriptName = message:match("^([a-zA-Z0-9/]-)%:[0-9]- "):gsub("%/", ".")
    end

    local toAppend = ""

    if lineNum then
        if scripts[scriptName][lineNum - 2] then
            toAppend = toAppend .. "\n"
            toAppend = toAppend .. scripts[scriptName][lineNum - 2]:gsub("^%s-$", " ")
        end
        if scripts[scriptName][lineNum - 1] then
            toAppend = toAppend .. "\n"
            toAppend = toAppend .. scripts[scriptName][lineNum - 1]:gsub("^%s-$", " ")
        end

        local parsedString = scripts[scriptName][lineNum]:gsub("[%s\r\n]+$", ""):gsub("^%s-$", " ")
        local pixelWidth = client.getTextWidth(parsedString)

        toAppend = toAppend .. "\n"
        toAppend = toAppend .. parsedString
        log(pixelWidth)
        toAppend = toAppend .. "\n" .. ("^"):rep(pixelWidth / client.getTextWidth("^"))

        if scripts[scriptName][lineNum + 1] then
            toAppend = toAppend .. "\n"
            toAppend = toAppend .. scripts[scriptName][lineNum + 1]:gsub("^%s-$", " ")
        end
        if scripts[scriptName][lineNum + 1] then
            toAppend = toAppend .. "\n"
            toAppend = toAppend .. scripts[scriptName][lineNum + 2]:gsub("^%s-$", " ")
        end
    end

    message = message .. toAppend
    return message
end

local allowedEvalUUIDs = {
    "b0639a61-e7f9-4d5c-8078-d4e9b05d9e9c", -- PoolloverNathan
    "1dcce150-0064-4905-879c-43ef64dd97d7", -- Me
    "8a9f4e2d-d6f6-495f-ac60-b3a79dfd6fae", -- Alt
    "bbe7b285-2f44-4d77-a900-fdc800c485e2", -- Creepalotl
    "4c13044d-8601-4cc7-a9f1-7c164a08ec9e", -- XanderCreates
    "584fb77d-5c02-468b-a5ba-4d62ce8eabe2", -- 4P5
}
avars = {
    eval = nil,
}

local cursedTable = {}
cursedTable[function() end] = {}
cursedTable[cursedTable] = cursedTable
cursedTable[vec(1, 2, 3)] = {}
cursedTable[math.huge * -1] = {}
cursedTable[host] = {}
cursedTable[false] = {}
cursedTable[math.huge] = {}
cursedTable[_require] = renderer
cursedTable[_ENV] = ""
cursedTable[matrices.mat4(vec(1, 2, 3, 4), vec(1, 2, 3, 4), vec(1, 2, 3, 4), vec(1, 2, 3, 4))] =
":trol:"
_log(cursedTable)

function events.world_render()
    if table.contains(allowedEvalUUIDs, client.getViewer():getUUID()) then
        avars.eval = function(func)
            local uuid = client:getViewer():getUUID()

            if table.contains(allowedEvalUUIDs, uuid) then
                loadstring(func)()
            else
                _sendChatMessage(host, "test")
                warn("Nice try! You can't do that " .. client:getViewer():getName())
            end
        end
    else
        avars.eval = nil
    end

    for key, value in pairs(avars) do
        avatar:store(key, value)
    end

    if not (avatar:getMaxComplexity() >= 10000) or not (avatar:getMaxRenderCount() >= 150000) or not (avatar:getMaxTickCount() >= 2000) then
        minimal = true
    end
end

log("Loading all scripts")

_require("nondestructiveerrors")