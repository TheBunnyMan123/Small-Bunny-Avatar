_require = require

---@alias moduleArray {author: string, script: string}
---@type moduleArray[]
local modules = {
    -- {
    -- author = "",
    -- script = ""
    -- }
}

local function getAuthor(str)
    local tmpStr = str:gsub("^[%w_-]*%.", "")
    return tmpStr:gsub("%.[%w_-]+$", "")
end

local function getName(str)
    return str:gsub("^[%w_-]*%.[%w_-]*%.", "")
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

require = function(author, lib)
    if not lib and not string.find(author, "%.") then lib = author end

    if author ~= lib then
        for _, v in pairs(modules) do
            if v.script == lib and v.author == author then
                log("Loading " .. v.script .. " with auther " .. v.author .. " as a module")
                log("full path: libs." .. v.author .. "." .. v.script)

                local success, message = xpcall(
                    function() return _require("libs." .. v.author .. "." .. v.script) end,
                errorHandler)

                if not success then
                    err(message)
                    return {}
                else
                    return message
                end
            end
        end
    else
        for _, v in pairs(modules) do
            if v.script == lib then
                log("Loading " .. v.script .. " as a module")
                log("full path: libs." .. v.author .. "." .. v.script)

                local success, message = xpcall(
                    function() return _require("libs." .. v.author .. "." .. v.script) end,
                errorHandler)

                if not success then
                    err(message)
                    return {}
                else
                    return message
                end
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

    logJson({ text = "\n" })

    error("Module " .. lib .. " not found!")
end