_require = require
_log = log

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

if not (avatar:getMaxComplexity() >= 10000) and (avatar:getMaxRenderCount() >= 150000) and (avatar:getMaxTickCount() >= 2000) then
    minimal = true
end

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
                text = "\n[WARN] ",
                color = "yellow",
            },
            {
                text = str,
                color = "yellow",
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
    local pattern = '%[[%s%S]-%]'                 -- Matches any characters within quotes inside brackets (single or double)

    local results = {}

    for line in string.gmatch(logTable(api, 1, true), "[^\n]*") do                               -- Iterate over lines using string.gmatch
        local capture = string.gmatch(line, pattern)()                      -- Start from the beginning of the line
        
        if capture then  
            local presubbed = string.gsub(capture, '%[%"', "")
            local subbed = string.gsub(presubbed, '%"%]', "")                                 -- Find the first match and stop after finding one
            table.insert(results, subbed)                                -- Add captured value
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
                text = "\n[DEBUG] ",
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
                    color = "white"
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

                    local toInsert = {
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
                            text = tostring(value),
                            color = colorFromValue(value),
                        },
                    }

                    for _, w in ipairs(toInsert) do
                        table.insert(hoverText, w)
                    end
                end
            end

            if isAPI(v) then
                -- log(type(getmetatable(v).__index))
                
                if type(getmetatable(v).__index) == "table" then
                    iterTable(getmetatable(v).__index)
                else
                    iterTable(metaTableFromMetaFunction(v, getmetatable(v).__index))
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
                    text = ((type(v) == "table" and tostring(v)) or type(v)),
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

    printf(out)
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

autoanims = require("auto_animations")

if file.allowed(file) and host:isHost() then
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
