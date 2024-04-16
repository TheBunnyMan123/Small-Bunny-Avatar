_require = require
_log = log

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

warn = function(str)
    printf(
                {
                    {
                        text = "\n[WARN] ",
                        color = "yellow"
                    },
                    {
                        text = str,
                        color = "yellow"
                    }
                }
            )
end

log = function(...)
    local inArgs = {...}

    for _, v in ipairs(inArgs) do
        if v == nil then
            warn("Tried to log nil value")
        end

        if type(v) == "string" then
            printf(
                {
                    {
                        text = "\n[DEBUG] ",
                        color = "gray"
                    },
                    {
                        text = v,
                        color = "white"
                    }
                }
            )
        else
            _log(v)
        end
    end
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

require = function(lib)
    for _, v in pairs(modules) do
        if v.script == lib then
            log("Loading ".. v.script .. " as a module")
            log("full path: libs." .. v.author .. "." .. v.script)

            return _require("libs." .. v.author .. "." .. v.script)
        end
    end
    
    printf({text = "\n"})

    error("Module " .. lib .. " not found!")
end

for _, v in pairs(listFiles("libs", true)) do
    local name = getName(v)
    local author = getAuthor(v)

    log("Adding "  .. author .. "." .. name .. " to modules")

    table.insert(modules, {
        author = author,
        script = name
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
                log("Loading " .. tostring(v))
                
                loadstring(file.readString(file, "scripts/" .. v))()
            end
        end
    else
        warn("Please run setup.sh in the avatar folder")
    end
end