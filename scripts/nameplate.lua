local badges = "ᚠᚡᚢᚣᚤᚥᚦᚧᚨᚩᚪᚫᚬᚭᚮᚯᚰᚱᚲᚳᚴᚵᚶᚷᚸ"

local color1 = vec(150, 255, 100)
local color2 = vec(50, 255, 150)
local steps = 10

local generatedSteps = {}

local nameplateFont = "default"
local fonts = "illageralt uniform alt default"

function pings.setNameFont(font)
    nameplateFont = font
end

local delta = (color2 - color1) / (steps - 1)

for i = 0, steps - 1 do
    table.insert(generatedSteps, color1 + (delta * i))
end

table.remove(generatedSteps, #generatedSteps)

delta = (color1 - color2) / (steps - 1)

for i = 0, steps - 1 do
    table.insert(generatedSteps, color2 + (delta * i))
end

table.remove(generatedSteps, #generatedSteps)

local tick = 1

local toLog = {}
for _, v in ipairs(generatedSteps) do
    table.insert(toLog, {
        text = '#',
        color = '#' .. vectors.rgbToHex(v / 255)
    })
end
log("Nameplate Gradient:")
logJson(toJson(toLog))

function events.tick()
    tick = tick + 1

    while tick > (steps * 2) - 2 do
        tick = tick - ((steps * 2) - 2)
    end
end

local iter = 0
function events.render()
    while tick > 100 do
        tick = tick - 100
    end

    errorTable = nil
    errorString = ""

    iter = 1

    for _, v in pairs(erroredFuncs) do
        if not (iter == 1) then
            errorString = errorString .. "\n-------------------------------------------\n"
        end

        errorString = errorString .. v

        iter = iter + 1
    end

    errorTable = {
        text = errorString,
        color = "red"
    }

    local nameHead = {
        {
            text = "${badges}",
            color = '#' .. vectors.rgbToHex(generatedSteps[tick] / 255)
        },
        {
            text = "ᚡ",
            color = "white",
            font = "figura:badges"
        },
        {
            text = "\n:rabbit: ",
            color = "white",
            font = nameplateFont
        },
    }

    if errorString ~= "" then
        -- _log(nameplateFont)
        nameHead = {
            {
                text = "${badges}",
                color = '#' .. vectors.rgbToHex(generatedSteps[tick] / 255)
            },
            {
                text = "ᚡ",
                color = "white",
                font = "figura:badges"
            },
            {
                text = " ❌",
                color = "#FF0000",
                hoverEvent = {
                    action = "show_text",
                    value = errorTable,
                }
            },
            {
                text = "\n:rabbit: ",
                color = "white",
                font = nameplateFont
            },
        }
    end

    iter = 0
    for i = tick, tick + 4 do
        iter = iter + 1

        local charToInsert = ''

        if iter == 1 then
            charToInsert = 'B'
        elseif iter == 2 then
            charToInsert = 'u'
        elseif iter == 3 then
            charToInsert = 'n'
        elseif iter == 4 then
            charToInsert = 'n'
        elseif iter == 5 then
            charToInsert = 'y'
        end

        local index = i
        while index > (steps * 2) - 2 do
            index = index - ((steps * 2) - 2)
        end

        table.insert(nameHead, {
            text = charToInsert,
            color = '#' .. vectors.rgbToHex(generatedSteps[index] / 255),
            font = nameplateFont
        })
    end

    avars.color = generatedSteps[tick] / 255
    avatar:setColor(generatedSteps[tick] / 255)
    avatar:setColor(generatedSteps[tick] / 255, "donator")

    iter = 0

    table.insert(nameHead, {
        text = " :rabbit:",
        color = "white",
        font = nameplateFont
    })

    nameplate.ALL:setText(toJson(nameHead))
    nameplate.ENTITY:setVisible(true):setOutline(true):setBackgroundColor(0, 0, 0, 0)
    -- models.model.root.Head.nameplate:setParentType("CAMERA"):newText("NAMEPLATE"):setText(toJson(nameHead)):setAlignment("CENTER"):scale(0.5):setPos(0, 8, 0)
    nameplate.ENTITY:setPivot(0, 1, 0)
    nameplate.ENTITY:setPos(0, 1, 0)
end