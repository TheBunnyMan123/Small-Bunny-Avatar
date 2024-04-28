---@alias TextComponentHoverEventAction ('show_text'|'show_item'|'show_entity')
---@alias TextComponentHoverEvent { action: TextComponentHoverEventAction, contents: string|TextJsonComponent }
---@alias TextComponentClickEventAction ('open_url'|'open_file'|'run_command'|'suggest_command')
---@alias TextComponentClickEvent { action_wheel: TextComponentClickEventAction, value: string }
---@alias color ('#<HEX>'|'black'|'dark_blue'|'dark_green'|'dark_aqua'|'dark_red'|'dark_purple'|'gold'|'gray'|'dark_gray'|'blue'|'green'|'aqua'|'red'|'light_purple'|'yellow'|'white')
---@alias TextJsonComponent { with?: TextJsonComponent[], text?: string, translate?: string, extra?: TextJsonComponent[], color?: color, font?: string, bold?: boolean, italic?: boolean, underlined?: boolean, strikethrough?: boolean, obfuscated?: boolean, insertion?: string, clickEvent?: TextComponentClickEvent, hoverEvent?: TextComponentHoverEvent }
---@alias BunnyChatUtils.RegistryFunction fun(self: BunnyChatUtils, chatJson: TextJsonComponent, rawText: string): TextJsonComponent, string

---@class BunnyChatUtils
local BunnyChatUtils = {
    ---@type BunnyChatUtils.RegistryFunction[][]
    __REGISTRY = {{},{},{},{},{}},
    __VARS = {},
}

---@param self BunnyChatUtils
---@param func BunnyChatUtils.RegistryFunction
---@param name string
function BunnyChatUtils.register(self, func, name, priority)
    if not priority then priority = 3 end

    self.__REGISTRY[math.clamp(priority, 1, 5)][name] = func
end

---@param self BunnyChatUtils
---@param rawText string
---@param jsonText TextJsonComponent
function BunnyChatUtils.process(self, rawText, jsonText)
    local newJsonText
    local newRawText
   
    for _, v in ipairs(self.__REGISTRY) do
        for _, w in pairs(v) do
            if not newJsonText then
                newJsonText, newRawText = w(self, jsonText, rawText)
            else
                newJsonText, newRawText = w(self, newJsonText, newRawText)
            end
        end
    end

    return newJsonText
end

---@param self BunnyChatUtils
---@param var string
function BunnyChatUtils.getCustomVar(self, var)
    return self.__VARS[var]
end

---@param self BunnyChatUtils
---@param var string
---@param val any
function BunnyChatUtils.setCustomVar(self, var, val)
    self.__VARS[var] = val
end

BunnyChatUtils:register(function(self, jsonText, rawText)
    if self:getCustomVar("prevText") == nil then
        self.__VARS["prevText"] = rawText
        self.__VARS["messageCount"] = 1
        return jsonText, rawText
    end

    if rawText:gsub("%s*$", "") == self.__VARS["prevText"]:gsub("%s*$", "") then
        self.__VARS["messageCount"] = self.__VARS["messageCount"] + 1
        -- print(jsonText.with)
        host:setChatMessage(1, nil)
        -- if jsonText.extra then
        if jsonText.extra then
            table.insert(jsonText.extra, { text = " (", color = "dark_gray" })
            table.insert(jsonText.extra, { text = "x", color = "gray" })
            table.insert(jsonText.extra,
                { text = tostring(self.__VARS["messageCount"]), color = "#A0FFA0" })
            table.insert(jsonText.extra, { text = ")", color = "dark_gray" })

            return jsonText, rawText
        elseif jsonText.with then
            jsonText.extra = {}

            table.insert(jsonText.extra, { text = " (", color = "dark_gray" })
            table.insert(jsonText.extra, { text = "x", color = "gray" })
            table.insert(jsonText.extra,
                { text = tostring(self.__VARS["messageCount"]), color = "#A0FFA0" })
            table.insert(jsonText.extra, { text = ")", color = "dark_gray" })
            return jsonText, rawText
        else
            table.insert(jsonText, { text = " (", color = "dark_gray" })
            table.insert(jsonText, { text = "x", color = "gray" })
            table.insert(jsonText,
                { text = tostring(self.__VARS["messageCount"]), color = "#A0FFA0" })
            table.insert(jsonText, { text = ")", color = "dark_gray" })

            return jsonText, rawText
        end
    end

    self.__VARS["prevText"] = rawText
    self.__VARS["messageCount"] = 1
    return jsonText, rawText
end, "BUILTIN.FILTER_SPAM")

BunnyChatUtils:register(function(self, jsonText, rawText)
    local time = client.getDate()
    minutes = time.minute
    hours = time.hour

    if tostring(minutes):len() < 2 then
        minutes = "0" .. minutes
    end

    local pm = false

    while hours > 12 do
        hours = hours - 12
        pm = true
    end

    local tmstmp = {
        {
            text = "",
            color = "white",
            bold = false,
            italic = false,
            underlined = false
        },
        {
            text = "[",
            color = "gray",
            bold = false,
            italic = false,
            underlined = false
        },
        {
            text = tostring(hours),
            color = "yellow",
            bold = false,
            italic = false,
            underlined = false
        },
        {
            text = ":",
            color = "white",
            bold = false,
            italic = false,
            underlined = false
        },
        {
            text = tostring(minutes),
            color = "yellow",
            bold = false,
            italic = false,
            underlined = false
        },
        {
            text = " " .. ((pm and "PM") or "AM"),
            color = "light_purple",
            bold = false,
            italic = false,
            underlined = false
        },
        {
            text = "] ",
            color = "gray",
            bold = false,
            italic = false,
            underlined = false
        },
    }

    local newTxt = {}

    for _, v in ipairs(tmstmp) do
        table.insert(newTxt, v)
    end

    table.insert(newTxt, jsonText)

    return newTxt, rawText
end, "BUILTIN.TIMESTAMPS")

BunnyChatUtils:register(function (_, chatJson, rawText)
    if chatJson.translate then
        if chatJson.translate == "multiplayer.player.left" then
            local plr = chatJson.with[1].insertion

            chatJson = {
                {
                    text = plr,
                    color = "aqua"
                },
                {
                    text = " left the game!",
                    color = "gray"
                }
            } --[[@as TextJsonComponent]]
        end

        goto done
    end

    ::done::

    return chatJson, rawText
end, 'BUILTIN.LEAVE', 1)

BunnyChatUtils:register(function (_, chatJson, rawText)
    if chatJson.translate then
        if chatJson.translate == "multiplayer.player.joined" then
            local plr = chatJson.with[1].insertion

            chatJson = {
                {
                    text = plr,
                    color = "aqua"
                },
                {
                    text = " joined the game!",
                    color = "gray"
                }
            } --[[@as TextJsonComponent]]
        end

        goto done
    end

    ::done::

    return chatJson, rawText
end, 'BUILTIN.JOIN', 1)

BunnyChatUtils:register(function (_, chatJson, rawText)
    if chatJson.translate then
        if chatJson.translate == "chat.type.text" then
            local plr = chatJson.with[1]

            local msg = chatJson.with[2]

            chatJson = {
                {
                    text = plr,
                    color = "white",
                    bold = false
                },
                {
                    text = " >> ",
                    color = "gray",
                    bold = true
                },
                {
                    text = msg,
                    color = "white",
                    bold = false
                }
            } --[[@as TextJsonComponent]]
        end

        goto done
    end

    ::done::

    return chatJson, rawText
end, 'BUILTIN.USERNAMEFORMAT', 1)

BunnyChatUtils:register(function (_, chatJson, rawText)
    if chatJson.translate then
        if chatJson.translate == "commands.message.display.outgoing" then
            local plrName = chatJson.with[1]
            local plr = ""
            for _, v in ipairs(plrName.extra) do
                plr = plr .. v
            end

            local msg = chatJson.with[2]

            if plrName.color == "white" then plrName.color = nil end

            chatJson = {
                {
                    text = "You",
                    color = "aqua",
                    bold = false
                },
                {
                    text = " --> ",
                    color = "gray",
                    bold = true
                },
                {
                    text = plr,
                    color = (not plrName.color and "yellow" or plrName.color),
                    bold = false
                },
                {
                    text = " >> ",
                    color = "gray",
                    bold = true
                },
                {
                    text = msg,
                    color = "white",
                    bold = false
                }
            } --[[@as TextJsonComponent]]
        end

        goto done
    end

    ::done::

    return chatJson, rawText
end, 'BUILTIN.MESSAGE.OUTGOING', 1)

BunnyChatUtils:register(function (_, chatJson, rawText)
    if chatJson.translate then
        if chatJson.translate == "commands.message.display.incoming" then
            local plrName = chatJson.with[1]
            local plr = ""
            for _, v in ipairs(plrName.extra) do
                plr = plr .. v
            end

            local msg = chatJson.with[2]

            if plrName.color == "white" then plrName.color = nil end

            chatJson = {
                {
                    text = plr,
                    color = (not plrName.color and "yellow" or plrName.color),
                    bold = false
                },
                {
                    text = " --> ",
                    color = "gray",
                    bold = true
                },
                {
                    text = "You",
                    color = "aqua",
                    bold = false
                },
                {
                    text = " >> ",
                    color = "gray",
                    bold = true
                },
                {
                    text = msg,
                    color = "white",
                    bold = false
                }
            } --[[@as TextJsonComponent]]
        end

        goto done
    end

    ::done::

    return chatJson, rawText
end, 'BUILTIN.MESSAGE.INCOMING', 1)

events.CHAT_RECEIVE_MESSAGE:register(function(rawText, jsonText)
    -- if not rawText:find("DEBUG") then
    --     log(jsonText)
    -- end

    return toJson(BunnyChatUtils:process(rawText, parseJson(jsonText) --[[@as TextJsonComponent]]))
end)

return BunnyChatUtils
