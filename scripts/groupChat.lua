---@diagnostic disable: param-type-mismatch
local messageCount = 1

function events.chat_receive_message(text, formatText)
    if text == prevText then
        messageCount = messageCount + 1
        host:setChatMessage(1, nil)
        local parsed = parseJson(formatText)
        if parsed.extra then
            table.insert(parsed.extra, {text = " (", color = "dark_gray"})
            table.insert(parsed.extra, {text = "x", color = "gray"})
            table.insert(parsed.extra, {text = tostring(messageCount), color = "#A0FFA0"})
            table.insert(parsed.extra, {text = ")", color = "dark_gray"})
            return toJson(parsed)
        elseif parsed then
            parsed = parseJson("[" .. formatText .. "]")
            table.insert(parsed, {text = " (x", color = "dark_gray"})
            table.insert(parsed, {text = tostring(messageCount), color = "#A0FFA0"})
            table.insert(parsed, {text = ")", color = "dark_gray"})
            return toJson(parsed)
        end
    else
        prevText = text
        messageCount = 1
        return formatText
    end
end