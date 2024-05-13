function err(msg)
    if type(msg) == "string" then
        msg = {{
            text = msg,
            color = "red"
        }}
    end

    table.insert(msg, 1, {
        text = "\n[ERROR] ",
        color = "red"
    })

    table.insert(msg, {text = "\n"})
    logJson(toJson(msg))
end


local avatarScripts = avatar:getNBT().scripts
scripts = {}
for k, v in pairs(avatarScripts) do
    scriptTbl = {}
    for _, w in pairs(v) do
        table.insert(scriptTbl, string.char(w % 256))
    end
    local script = table.concat(scriptTbl)
    scripts[k] = string.split(script, "\n")
end

local registerEvent = figuraMetatables.EventsAPI.__newindex
local registerEventWithName = figuraMetatables.Event.__index.register

figuraMetatables.Event.__index.register = function(self, func, name)
    local newFunc = function(...)
        local packed = {...}
        if not erroredFuncs[func] then
            local success, message = xpcall(
                function() 
                    return func(table.unpack(packed))
                end,
            errorHandler)

            if not success then
                err(message)
                erroredFuncs[func] = message
            end

            if success then
                return message
            end
        end
    end

    registerEventWithName(self, newFunc, name)
end

errorString = nil

erroredFuncs = {}

figuraMetatables.EventsAPI.__newindex = function(self, key, func)
    local newFunc = function(...)
        local packed = {...}
        if not erroredFuncs[func] then
            local success, message = xpcall(
                function() 
                    return func(table.unpack(packed))
                end,
            errorHandler)

            if not success then
                err(message)
                erroredFuncs[func] = message
            end

            if success then
                return message
            end
        end
    end

    registerEvent(self, key, newFunc)
end

for _, v in pairs(listFiles("scripts", true)) do
    log("Loading " .. v)
    
    local success, message = xpcall(
        function() _require(v) end,
    errorHandler)

    if not success then
        err(message)
        erroredFuncs[v] = message
    end
end

if host:isHost() and file.allowed(file) and not minimal then
    local files = file.list(file, "scripts")
    if files then
        log()
        for _, v in pairs(files) do
            if string.gmatch(v, ".%a+.lua.link") then
                if not file:isDirectory("scripts/" .. v) then
                    log("Loading " .. tostring(v))
                    local success, message = xpcall(
                        loadstring(file.readString(file, "scripts/" .. v)),
                    errorHandler)

                    if not success then
                        err("Host only script " .. tostring(v) .. " errored! (" .. message .. ")")
                        erroredFuncs[v] = message
                    end
                end
            end
        end
    else
        warn("Please run setup.sh in the avatar folder")
    end
end