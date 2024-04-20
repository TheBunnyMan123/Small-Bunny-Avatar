local color1 = vec(44, 255, 187)
local color2 = vec(150, 255, 150)
local steps = 50

local generatedSteps = {}

local delta = (color2 - color1) / (steps - 1)

for i = 0, steps - 1 do
    table.insert(generatedSteps, color1 + (delta * i))
end

delta = (color1 - color2) / (steps - 1)

for i = 0, steps - 1 do
    table.insert(generatedSteps, color2 + (delta * i))
end

local tick = 0

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

    while tick > 100 do
        tick = tick - 100
    end
end

local iter = 0
function events.render()
    local nameHead = {
        {
            text = "${badges}",
            color = "white",
        },
        {
            text = "\n:rabbit: ",
            color = "white",
        },
    }

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
        while index > 100 do
            index = index - 100
        end

        table.insert(nameHead, {
            text = charToInsert,
            color = '#' .. vectors.rgbToHex(generatedSteps[index] / 255)
        })
        -- log(i, iter)
    end
    iter = 0

    table.insert(nameHead, {
        text = " :rabbit:",
        color = "white",
    })

    nameplate.ALL:setText(toJson(nameHead))
    nameplate.ENTITY:setPivot(0, 1, 0)
    nameplate.ENTITY:setPos(0, 1, 0)
end