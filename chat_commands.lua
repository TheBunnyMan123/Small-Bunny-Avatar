local function splitString(str, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local tbl = {}
    for split in str:gmatch("([^" .. seperator .. "]+)") do
        table.insert(tbl, split)
    end
    return tbl
end
local function printf(tbl)
    logJson(toJson(tbl))
end

local prefix = "."

local cmdQueue = {}
-- Make a local variable for commands so the help command can access it
local commands
commands = {
    {
        cmd = "help",
        desc = "List all commands, their arguments and description",
        args = {},
        func = function(args)
            local toSend = {
                { text = "\n---------------", color = "gray" },
                { text = " COMMANDS ",        color = "green" },
                { text = "---------------",   color = "gray" },
            }                                                    -- The commands header
            for _, v in ipairs(commands) do
                table.insert(toSend, { text = "\n" .. v.cmd, color = "light_purple" }) -- The command name

                for _, w in ipairs(v.args) do
                    table.insert(toSend, {
                        text = w.required and (" {" .. w.arg .. "}") or (" [" .. w.arg .. "]"),
                        color = w.required and "red" or "yellow",
                    })                                                                   -- Argument
                end
                table.insert(toSend, { text = " | ", color = "gray" })                   -- Seperator
                table.insert(toSend, { text = v.desc, color = "green" })                 -- Description
            end
            table.insert(toSend, { text = "\n----------------------------------------", color = "gray" }) -- Footer
            printf(toSend)
        end,
    },
    {
        cmd = "ride",
        desc = "Summon and ride an Entity",
        args = {
            {
                arg = "str: entity",
                required = true,
            },
            {
                arg = "int: speed",
                required = false,
            },
        },
        func = function(args)
            local summonStr = ""

            if not args or #args == 0 then return false end

            if #args >= 2 then
                summonStr = "summon " ..
                args[1] ..
                " ~ ~ ~ {Attributes:[{Name:generic.movement_speed,Base:" ..
                args[2] .. "}],Tags:[\"ToRide\"]}"
            else
                summonStr = "summon " .. args[1] .. " ~ ~ ~ {Tags:[\"ToRide\"]}"
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
                arg = "str: entity",
                required = true,
            },
            {
                arg = "int: amount",
                required = false,
            },
        },
        func = function(args)
            if not args or #args < 1 then return false end
            if args[2] == nil then args[2] = 1 end

            for _ = 1, args[2] do
                table.insert(cmdQueue, "summon " .. args[1] .. " ~ ~ ~ {Tags:[\"BulkSummon\"]}")
            end

            return true
        end,
    },
    {
        cmd = "tilegen",
        desc = "Generate",
        args = {
            {
                arg = "vec2: tile array size (x, y)",
                required = true,
            },
            {
                arg = "vec3: tile size (length, width, height)",
                required = true,
            },
            {
                arg = "vec3: origin",
                required = true,
            },
            {
                arg = "vec2: world size (x, y)",
                required = true,
            },
        },
        func = function(args)
            if not args or #args < 10 then return false end

            require("libs.tilegen"):generate(vec(args[1], args[2]), vec(args[3], args[4], args[5]), vec(args[6], args[7], args[8]), vec(args[9], args[10]))

            return true
        end,
    },
    {
        cmd = "gridgen",
        desc = "Generate",
        args = {
            {
                arg = "vec2: tile size (length, width)",
                required = true,
            },
            {
                arg = "vec3: origin",
                required = true,
            },
            {
                arg = "vec2: world size (x, y)",
                required = true,
            },
        },
        func = function(args)
            if not args or #args < 7 then return false end

            require("libs.gridgen"):generate(vec(args[1], args[2]), vec(args[3], args[4], args[5]), vec(args[6], args[7]))

            return true
        end,
    },
}

-- A mirror of the top, using the command name as the index. This makes command access a lot simpler later
local cmds = {}
-- Copy everything in commands and set their index to the command name if the index is a number
for i, cmd in pairs(commands) do
    if (type(i) == "number") then
        cmds[cmd.cmd] = cmd
    else
        cmds[i] = cmd
    end
end

events.CHAT_SEND_MESSAGE:register(function(msg)
    -- No reason to do anything unless the prefix is in the message
    -- Guard clause instead of massive if statement, this can make code easier to read, understand and shorter
    if (msg:sub(1, #prefix) ~= prefix) then return msg end
    local split = splitString(msg, " ")
    -- Instead of looping through the entire table, we remove the prefix from split[1], then index the cmds table
    local command = cmds[split[1]:sub(#prefix + 1)]
    -- Return if the command doesn't exist
    if (not command) then return msg end

    -- Remove the command itself
    table.remove(split, 1)
    if command.func(split) == false then
        local toSend = {
            { text = "Invalid Command Usage. Usage: ", color = "dark_red" },
            { text = command.cmd,                      color = "light_purple" },
        } -- The command name

        for _, w in ipairs(command.args) do
            table.insert(toSend, {
                text = w.required and (" {" .. w.arg .. "}") or (" [" .. w.arg .. "]"),
                color = w.required and "red" or "yellow",
            }) -- Argument
        end
        printf(toSend)
    end
    host:appendChatHistory(msg)

    return
end, "COMMANDS.SEND_MESSAGE")

events.tick:register(function()
    if (#cmdQueue == 0) then return end -- Return if cmdQueue is empty
    local count = 5                 -- A count, to not spam commands
    while #cmdQueue ~= 0 and count > 0 do
        count = count - 1
        host:sendChatCommand(table.remove(cmdQueue, 1))
    end
end, "COMMANDS.TICK")
