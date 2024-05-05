_require = require
_log = log
_sendChatCommand = host.sendChatCommand
_sendChatMessage = host.sendChatMessage

minimal = false
figcolors = {
    AWESOME_BLUE = "#5EA5FF",
    PURPLE = "#A672EF",
    BLUE = "#00F0FF",
    SOFT_BLUE = "#99BBEE",
    RED = "#FF2400",
    ORANGE = "#FFC400",

    CHEESE = "#F8C53A",

    LUA_LOG = "#5555FF",
    LUA_ERROR = "#FF5555",
    LUA_PING = "#A155DA",

    DEFAULT = "#5AAAFF",
    DISCORD = "#5865F2",
    KOFI = "#27AAE0",
    GITHUB = "#FFFFFF",
    MODRINTH = "#1BD96A",
    CURSEFORGE = "#F16436",
}

if not (avatar:getMaxComplexity() >= 10000) or not (avatar:getMaxRenderCount() >= 150000) or not (avatar:getMaxTickCount() >= 2000) then
    minimal = true
end

---@alias moduleArray {author: string, script: string}
---@type moduleArray[]
local modules = {
    -- {
    -- author = "",
    -- script = ""
    -- }
}

printf = function(arg)
    if type(arg) == "string" then
        logJson(arg)
    else
        logJson(toJson(arg))
    end
end

logf = printf

function isAPI(arg)
    local mtbl = getmetatable(arg)

    if not mtbl then
        return false
    end

    if type(mtbl.__index) == "table" or type(mtbl.__index) == "function" then
        return true
    else
        return false
    end
end

warn = function(str)
    printf(
        {
            {
                text = "[WARN] ",
                color = "yellow",
            },
            {
                text = str,
                color = "yellow",
            },
            {
                text = "\n",
            },
        }
    )
end

function colorFromValue(arg)
    if type(arg) == "string" then
        return "white"
    elseif type(arg) == "table" then
        return figcolors.AWESOME_BLUE
    elseif type(arg) == "boolean" then
        return figcolors.LUA_PING
    elseif type(arg) == "function" then
        return "green"
    elseif type(arg) == "number" then
        return figcolors.BLUE
    elseif type(arg) == "nil" then
        return figcolors.LUA_ERROR
    elseif type(arg) == "thread" then
        return "gold"
    else
        return "yellow"
    end
end

function string.split(input, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. seperator .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function metaTableFromMetaFunction(api, func)
    local mtable = {}
    local pattern =
    "%[[%s%S]-%]" -- Matches any characters within quotes inside brackets (single or double)

    local results = {}

    for line in string.gmatch(logTable(api, 1, true), "[^\n]*") do -- Iterate over lines using string.gmatch
        local capture = string.gmatch(line, pattern)()             -- Start from the beginning of the line

        if capture then
            local presubbed = string.gsub(capture, '%[%"', "")
            local subbed = string.gsub(presubbed, '%"%]', "") -- Find the first match and stop after finding one
            table.insert(results, subbed)                     -- Add captured value
        end
    end

    for _, v in pairs(results) do
        mtable[v] = func(api, v)
    end

    return mtable
end

log = function(...)
    local inArgs = table.pack(...)
    local out = {
        {
            {
                text = "[DEBUG] ",
                color = "gray",
            },
        },
    }

    for i = 1, inArgs.n do
        v = inArgs[i]
        if i ~= 1 then
            table.insert(out, {
                text = "    ",
                color = "white",
            })
        end

        ::begin::

        if v == nil then
            table.insert(out,
                {
                    text = "nil",
                    color = colorFromValue(nil),
                }
            )
        elseif string.lower(type(v)):find("matrix") or string.lower(type(v)):find("vector") then
            table.insert(out,
                {
                    text = tostring(v),
                    color = colorFromValue(v),
                }
            )
        elseif type(v) == "string" then
            table.insert(out,
                {
                    text = v,
                    color = colorFromValue(v),
                }
            )
        elseif type(v) == "table" or isAPI(v) then
            local hoverText = {
                {
                    text = type(v),
                    color = colorFromValue(v),
                },
                {
                    text = ": ",
                    color = "white",
                },
                {
                    text = "{\n",
                    color = "gray",
                },
            }

            local function iterTable(tbl)
                for key, value in pairs(tbl) do
                    if type(value) == "string" then
                        value = "\"" .. value .. "\""
                    end

                    local str = tostring(value)

                    if v.getName then
                        if type(v.getName) == "function" then
                            if v:getName() ~= nil then
                                str = type(v) .. " (" .. v:getName() .. ")"
                            end
                        end
                    elseif v.getTitle then
                        if type(v.getTitle) == "function" then
                            if v:getTitle() ~= nil then
                                str = type(v) .. " (" .. v:getTitle() .. ")"
                            end
                        end
                    end

                    local toInsert = {}

                    if type(key) == "number" then
                        toInsert = {
                            {
                                text = "\n  [",
                                color = "gray",
                            },
                            {
                                text = "" .. key .. "",
                                color = colorFromValue(key),
                            },
                            {
                                text = "] = ",
                                color = "gray",
                            },
                            {
                                text = str,
                                color = colorFromValue(value),
                            },
                        }
                    else
                        toInsert = {
                            {
                                text = "\n  [",
                                color = "gray",
                            },
                            {
                                text = "\"" .. key .. "\"",
                                color = "white",
                            },
                            {
                                text = "] = ",
                                color = "gray",
                            },
                            {
                                text = str,
                                color = colorFromValue(value),
                            },
                        }
                    end

                    for _, w in ipairs(toInsert) do
                        table.insert(hoverText, w)
                    end
                end
            end

            local modstr = ""

            if isAPI(v) then
                if type(getmetatable(v).__index) == "table" then
                    if v.getName then
                        if type(v.getName) == "function" then
                            if v:getName() ~= nil then
                                modstr = " (" .. v:getName() .. ")"
                            end
                        end
                    elseif v.getTitle then
                        if type(v.getTitle) == "function" then
                            if v:getTitle() ~= nil then
                                modstr = " (" .. v:getTitle() .. ")"
                            end
                        end
                    end

                    if v.getChildren then
                        iterTable(v:getChildren())
                    else
                        iterTable(getmetatable(v).__index)
                    end
                else
                    if v.getName then
                        if type(v.getName) == "function" then
                            if v:getName() ~= nil then
                                modstr = " (" .. v:getName() .. ")"
                            end
                        end
                    elseif v.getTitle then
                        if type(v.getTitle) == "function" then
                            if v:getTitle() ~= nil then
                                modstr = " (" .. v:getTitle() .. ")"
                            end
                        end
                    end

                    if v.getChildren then
                        iterTable(v:getChildren())
                    else
                        iterTable(metaTableFromMetaFunction(v, getmetatable(v).__index))
                    end
                end
                goto continue
            end

            iterTable(v)

            ::continue::
            table.insert(hoverText, {
                text = "\n}",
                color = "gray",
            })

            table.insert(out,
                {
                    text = ((type(v) == "table" and tostring(v)) or type(v) .. modstr),
                    color = colorFromValue(v),
                    hoverEvent = {
                        action = "show_text",
                        value = hoverText,
                    },
                }
            )
        elseif v ~= nil then
            table.insert(out,
                {
                    text = tostring(v),
                    color = colorFromValue(v),
                }
            )
        end
    end

    table.insert(out, {
        text = "\n",
    })

    printf(out)
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

local function getAuthor(str)
    local tmpStr = str:gsub("^[%w_-]*%.", "")
    return tmpStr:gsub("%.[%w_-]+$", "")
end

local function getName(str)
    return str:gsub("^[%w_-]*%.[%w_-]*%.", "")
end

--Add ---@class [LIB] right before the table returned, and then when required add "--[[@as [LIB]]]" to the end of the line
require = function(author, lib)
    if not lib and not string.find(author, "%.") then lib = author end

    if author ~= lib then
        for _, v in pairs(modules) do
            if v.script == lib and v.author == author then
                log("Loading " .. v.script .. " with auther " .. v.author .. " as a module")
                log("full path: libs." .. v.author .. "." .. v.script)

                return _require("libs." .. v.author .. "." .. v.script)
            end
        end
    else
        for _, v in pairs(modules) do
            if v.script == lib then
                log("Loading " .. v.script .. " as a module")
                log("full path: libs." .. v.author .. "." .. v.script)

                return _require("libs." .. v.author .. "." .. v.script)
            end
        end
    end

    -- log(author)

    if string.find(author, "^%.@") and host:isHost() then
        log("Loading host only module " .. author)
        return loadstring(file:readString("scripts/require/" .. author .. ".lua.link"))()
    elseif string.find(author, "%.") then
        log("Loading " .. author .. " as a module")

        return _require(author)
    end

    printf({ text = "\n" })

    error("Module " .. lib .. " not found!")
end

function gradient(color1, color2, steps)
    local generatedSteps = {}

    local delta = (color2 - color1) / (steps - 1)

    for i = 0, steps - 1 do
        table.insert(generatedSteps, color1 + (delta * i))
    end

    return generatedSteps
end

for _, v in pairs(listFiles("libs", true)) do
    local name = getName(v)
    local author = getAuthor(v)

    log("Adding " .. author .. "." .. name .. " to modules")

    table.insert(modules, {
        author = author,
        script = name,
    })
end

for _, v in pairs(listFiles("scripts", true)) do
    log("Loading " .. v)
    _require(v)
end

BunnyChatUtils = require("BunnyChatUtils")
autoanims = require("auto_animations")
base64 = require("base64") --[[@as base64lib]]

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

if file.allowed(file) and host:isHost() and not minimal then
    local files = file.list(file, "scripts")
    if files then
        log()
        for _, v in pairs(files) do
            if string.gmatch(v, ".%a+.lua.link") then
                if not file:isDirectory("scripts/" .. v) then
                    log("Loading " .. tostring(v))

                    loadstring(file.readString(file, "scripts/" .. v))()
                end
            end
        end
    else
        warn("Please run setup.sh in the avatar folder")
    end
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
    entities = {
        [1] = {
            pos = vec(0, 0, 0),
            hitbox = {
                (vec(0, 0, 0)) - vec(0.4, 0.3, 0.4),
                (vec(0, 0, 0)) + vec(0.4, 0.3, 0.4),
            },
        },
    },
    renderer = renderer,
    eval = nil,
}

entities = {
    drone = {
        pos = vec(0, 0, 0),
        hitbox = {
            (vec(0, 0, 0)) - vec(0.4, 0.3, 0.4),
            (vec(0, 0, 0)) + vec(0.4, 0.3, 0.4),
        },
    },
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

    avars.entities = {}

    local iter = 0
    for _, v in pairs(entities) do
        iter = iter + 1
        avars.entities[iter] = v
    end

    for key, value in pairs(avars) do
        avatar:store(key, value)
    end

    if not (avatar:getMaxComplexity() >= 10000) or not (avatar:getMaxRenderCount() >= 150000) or not (avatar:getMaxTickCount() >= 2000) then
        minimal = true
    end
end
