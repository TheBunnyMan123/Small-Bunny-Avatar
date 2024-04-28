local alreadyDead = false

function deathEvent()
    local pos = player:getPos()
    pos = pos:floor()

    local msg = {
        {
            text = "You ",
            color = "gray",
            bold = false
        },
        {
            text = "died!",
            color = "red",
            bold = true
        },
        {
            text = " Your death position is ",
            color = "gray",
            bold = false
        },
        {
            text = tostring(pos):gsub("^{", ""):gsub("}$", ""):gsub(",", ""),
            color = "yellow",
            clickEvent = {
                action = "suggest_command",
                value = "/execute in " .. player:getDimensionName() .. " run tp @s " .. pos.x .. " " .. pos.y .. " " .. pos.z
            },
            hoverEvent = {
                action = "show_text",
                value = {
                    {
                        text = "Click",
                        color = "yellow"
                    },
                    {
                        text = " to ",
                        color = "gray"
                    },
                    {
                        text = "teleport",
                        color = "yellow"
                    }
                }
            }
        }
    }

    printf(msg)
end

events.tick:register(function ()
    if not player:isLoaded() then return end
    if alreadyDead and player:isAlive() then
        alreadyDead = false
    end

    if not alreadyDead and not player:isAlive() then
        alreadyDead = true
        deathEvent()
    end
end, 'DEATH_EVENT')