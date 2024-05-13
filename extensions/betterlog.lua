_log = log
_logJson = logJson

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

function metaTableFromMetaMethod(api, func)
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

logJson = function(arg)
    if type(arg) == "string" then
        _logJson(arg)
    else
        _logJson(toJson(arg))
    end
end

warn = function(str)
    logJson(
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
                        iterTable(metaTableFromMetaMethod(v, getmetatable(v).__index))
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

    logJson(out)
end