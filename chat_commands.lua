local function splitString(string, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local tbl = {}
    for str in string.gmatch(string, "([^" .. seperator .. "]+)") do
        table.insert(tbl, str)
    end
    return tbl
end

local prefix = "."

local cmdQueue = {}

local commands = {
    {
        -- Since the help command requires access to this table, it is hardcoded. I just have it here so that it shows up
        cmd = "help",
        desc = "Display commands",
        args = {},
        func = function(args)
        end,
    },
    {
        cmd = "ride",
        desc = "Ride an Entity",
        args = {
            {
                arg = "str: entity", 
                required = true
            },
            {
                arg = "int: speed", 
                required = false
            }
        },
        func = function(args)
            local summonStr = ""

            if not args then return false end

            if #args >= 2 then
                summonStr = "summon " .. args[1] .. " ~ ~ ~ {Attributes:[{Name:generic.movement_speed,Base:" .. args[2] .. "}],Tags:[\"ToRide\"]}"
            elseif #args >= 1 then
                summonStr = "summon " .. args[1] .. " ~ ~ ~ {Tags:[\"ToRide\"]}"
            else
                return false
            end

            host:sendChatCommand(summonStr)
            host:sendChatCommand("ride @s mount @e[type=" .. args[1] .. ",sort=nearest,limit=1,tag=ToRide]")

            return true
        end,
    },
    {
        cmd = "summon",
        desc = "Summon a specified amount of an entity",
        args = {
            {
                arg = "int: amount", 
                required = true
            },
            {
                arg = "str: entity", 
                required = true
            }
        },
        func = function(args)
            if not args then return false end

            if #args >= 2 then
                for _ = 1, args[1], 1 do
                    table.insert(cmdQueue, "summon " .. args[2] .. " ~ ~ ~ {Tags:[\"BulkSummoned\"]}")
                end
            else
                return false
            end

            return true
        end,
    }
}

function events.tick()
    if #cmdQueue >= 1 then
        if #cmdQueue < 5 then
            for i = 1, 5, 1 do
                host:sendChatCommand(cmdQueue[1])

                table.remove(cmdQueue, 1)
            end
        else
            for i = 1, #cmdQueue, 1 do
                host:sendChatCommand(cmdQueue[1])

                table.remove(cmdQueue, 1)
            end
        end
    end
end

function events.CHAT_SEND_MESSAGE(msg)
    local split = splitString(msg, " ")

    if split[1] == prefix .. "help" then
        logJson(toJson({text = "\n--------------- COMMANDS ---------------"}))

        for _, v in ipairs(commands) do
            local toSend = v.cmd

            for _, w in ipairs(v.args) do
                if w.required then
                    toSend = toSend .. " {"
                    toSend = toSend .. w.arg
                    toSend = toSend .. "}"
                else
                    toSend = toSend .. " ["
                    toSend = toSend .. w.arg
                    toSend = toSend .. "]"
                end
            end

            toSend = toSend .. " - "
            toSend = toSend .. v.desc

            logJson(toJson({text = "\n" .. toSend}))
        end

        logJson(toJson({text = "\n----------------------------------------"}))

        host:appendChatHistory(msg)

        return
    end

    for _, v in pairs(commands) do
        if split[1] == prefix .. v.cmd then
            table.remove(split, 1)
            if v.func(split) == false then
                logJson(toJson({text = "Invalid Command Usage. Run " .. prefix .. "help to find the correct usage", color = "red"}))
            end

            host:appendChatHistory(msg)

            return
        end
    end

    return msg
end
