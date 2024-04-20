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
            }
            
                                             -- The commands header
            for _, v in ipairs(commands) do
                table.insert(toSend, { text = "\n" .. v.cmd, color = "light_purple" }) -- The command name

                for _, w in ipairs(v.args) do
                    table.insert(toSend, {
                        text = w.required and (" {" .. w.arg .. "}") or (" [" .. w.arg .. "]"),
                        color = w.required and "red" or "yellow",
                    })                                                   -- Argument
                end
                table.insert(toSend, { text = " | ", color = "gray" })   -- Seperator
                table.insert(toSend, { text = v.desc, color = "green" }) -- Description
            end
            table.insert(toSend,
                { text = "\n----------------------------------------", color = "gray" }) -- Footer
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
            host:sendChatCommand("ride @s mount @e[type=" ..
                args[1] .. ",sort=nearest,limit=1,tag=ToRide]")

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
        desc = "Generate a tilemapped area",
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

            local tilegen = require(".@tilegen")--[[@as tilegen]]
            tilegen:generate(vec(args[1], args[2]), vec(args[3], args[4], args[5]), 
                vec(args[6], args[7], args[8]), vec(args[9], args[10]))

            return true
        end,
    },
    {
        cmd = "gradient",
        desc = "Gradient Test",
        args = {
            {
                arg = "vec3: Color 1 (0-255)",
                required = true
            },
            {
                arg = "vec3: Color 2 (0-255)",
                required = true
            },
            {
                args = "int: steps",
                required = true
            }
        },
        func = function(args)
            if not args or #args < 7 then return false end

            local color1 = vec(args[1], args[2], args[3])
            local color2 = vec(args[4],args[5],args[6])
            local steps = args[7]

            local generatedSteps = {}

            local delta = (color2 - color1) / (steps - 1)

            for i = 0, steps - 1 do
                table.insert(generatedSteps, color1 + (delta * i))
            end

            local strToLog = {}

            for _, v in ipairs(generatedSteps) do
                table.insert(strToLog, {
                    text = "#",
                    color = "#" .. vectors.rgbToHex(v / 255)
                })
            end

            printf(strToLog)
        end
    },
    {
        cmd = "gridgen",
        desc = "Generate a grid",
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

            local gridgen = require(".@gridgen") --[[@as gridgen]]
            gridgen:generate(vec(args[1], args[2]), vec(args[3], args[4], args[5]),
                vec(args[6], args[7]))

            return true
        end,
    },
    -- {
    --     cmd = "waypoint",
    --     desc = "Get code for adding a waypoint",
    --     args = {},
    --     func = function(args)
    --         local serverData = client.getServerData()

    --         if not serverData.ip then
    --             serverData.ip = "none"
    --         end

    --         local playerPos = player:getPos()

    --         logJson(
    --             toJson(
    --                 {
    --                     text = '{name="NAME",server="'..serverData.ip .. " - " .. serverData.name..'",pos=vec(' .. math.floor(playerPos.x) .. "," .. math.floor(playerPos.y) .. "," .. math.floor(playerPos.z) .. ")"..',dimension="'..world.getDimension()..'",}'
    --                 }

    --             )
    --         )
    --     end,
    -- },
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

function isUrl(str)
    local URLPART = "[%w@:%%._\\+~#=]"

    local pattern = "^https?://" ..
        URLPART .. "+"

    return string.find(str, pattern) ~= nil
end

-- local urls = {"mailto:4p5.nz", "sftp://tset.com/test", "http://www.youtube.com", "http://www.facebook.com", "http://www.baidu.com", "http://www.yahoo.com", "http://www.amazon.com", "http://www.wikipedia.org", "http://www.qq.com", "http://www.google.co.in", "http://www.twitter.com", "http://www.live.com", "http://www.taobao.com", "http://www.bing.com", "http://www.instagram.com", "http://www.weibo.com", "http://www.sina.com.cn", "http://www.linkedin.com", "http://www.yahoo.co.jp", "http://www.msn.com", "http://www.vk.com", "http://www.google.de", "http://www.yandex.ru", "http://www.hao123.com", "http://www.google.co.uk", "http://www.reddit.com", "http://www.ebay.com", "http://www.google.fr", "http://www.t.co", "http://www.tmall.com", "http://www.google.com.br", "http://www.360.cn", "http://www.sohu.com", "http://www.amazon.co.jp", "http://www.pinterest.com", "http://www.netflix.com", "http://www.google.it", "http://www.google.ru", "http://www.microsoft.com", "http://www.google.es", "http://www.wordpress.com", "http://www.gmw.cn", "http://www.tumblr.com", "http://www.paypal.com", "http://www.blogspot.com", "http://www.imgur.com", "http://www.stackoverflow.com", "http://www.aliexpress.com", "http://www.naver.com", "http://www.ok.ru", "http://www.apple.com", "http://www.github.com", "http://www.chinadaily.com.cn", "http://www.imdb.com", "http://www.google.co.kr", "http://www.fc2.com", "http://www.jd.com", "http://www.blogger.com", "http://www.163.com", "http://www.google.ca", "http://www.whatsapp.com", "http://www.amazon.in", "http://www.office.com", "http://www.tianya.cn", "http://www.google.co.id", "http://www.youku.com", "http://www.rakuten.co.jp", "http://www.craigslist.org", "http://www.amazon.de", "http://www.nicovideo.jp", "http://www.google.pl", "http://www.soso.com", "http://www.bilibili.com", "http://www.dropbox.com", "http://www.xinhuanet.com", "http://www.outbrain.com", "http://www.pixnet.net", "http://www.alibaba.com", "http://www.alipay.com", "http://www.microsoftonline.com", "http://www.booking.com", "http://www.googleusercontent.com", "http://www.google.com.au", "http://www.popads.net", "http://www.cntv.cn", "http://www.zhihu.com", "http://www.amazon.co.uk", "http://www.diply.com", "http://www.coccoc.com", "http://www.cnn.com", "http://www.bbc.co.uk", "http://www.twitch.tv", "http://www.wikia.com", "http://www.google.co.th", "http://www.go.com", "http://www.google.com.ph", "http://www.doubleclick.net", "http://www.onet.pl", "http://www.googleadservices.com", "http://www.accuweather.com", "http://www.googleweblight.com", "http://www.answers.yahoo.com"}

-- for _, v in pairs(urls) do
--     log(v, isUrl(v))
-- end

events.CHAT_SEND_MESSAGE:register(function(msg)
    -- No reason to do anything unless the prefix is in the message
    -- Guard clause instead of massive if statement, this can make code easier to read, understand and shorter
    if isUrl(msg) and player:getPermissionLevel() > 1 then
        local str = ('tellraw @a [{"text":"<TheKillerBunny> "},{"text":"%s","color":"aqua","underlined":true,"clickEvent":{"action":"open_url","value":"%s"}}]'):format(msg, msg)
        if str:len() < 256 then
            host:sendChatCommand(str)
            return
        end
    elseif (msg:sub(1, #prefix) ~= prefix) then return msg end
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
end, "COMMANDS.SEND_MESSAGE")