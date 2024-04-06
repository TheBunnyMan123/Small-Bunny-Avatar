mainPage = action_wheel:newPage()
function pings.bababoy3()
   sounds:playSound("music.game", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Overworld - various artists")
    :item("minecraft:grass_block")
    :hoverColor(0,1,0)
    :onLeftClick(pings.bababoy3)

function pings.bababoy3()
   sounds:playSound("music.menu", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Menu - Lena Raine")
    :item("minecraft:gray_stained_glass_pane")
    :hoverColor(5,5,5)
    :onLeftClick(pings.bababoy3)

function pings.bababoy20()
   sounds:playSound("music.credits", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Credits - C418")
    :item("minecraft:filled_map")
    :hoverColor(1,2,1)
    :onLeftClick(pings.bababoy20)

local action = mainPage:newAction()
    :title("Music Player by RedNinja__")
    :item("minecraft:filled_map")

action_wheel:setPage(mainPage)

function pings.bababoy2()
   sounds:playSound("block.bell.use", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("bell")
    :item("minecraft:bell")
    :hoverColor(1,1,0)
    :onLeftClick(pings.bababoy2)
action_wheel:setPage(mainPage)

function pings.bababoy8()
   sounds:playSound("music_disc.stal", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Stal - C418")
    :item("minecraft:music_disc_stal")
    :hoverColor(0,0,0)
    :onLeftClick(pings.bababoy8)

function pings.bababoy18()
   sounds:playSound("music_disc.chirp", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Chirp - C418")
    :item("minecraft:music_disc_chirp")
    :hoverColor(0,0,0)
    :onLeftClick(pings.bababoy18)

action_wheel:setPage(mainPage)

function pings.bababoy69()
   sounds:playSound("music_disc.mellohi", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Mellohi - C418")
    :item("minecraft:music_disc_mellohi")
    :hoverColor(0,0,0)
    :onLeftClick(pings.bababoy69)

action_wheel:setPage(mainPage)

function pings.bababoy6()
   sounds:playSound("music_disc.ward", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Ward - C418")
    :item("minecraft:music_disc_ward")
    :hoverColor(0,0,0)
    :onLeftClick(pings.bababoy6)

function pings.bababoy4()
   sounds:playSound("music_disc.strad", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Strad - C418")
    :item("minecraft:music_disc_strad")
    :hoverColor(0,0,0)
    :onLeftClick(pings.bababoy4)

action_wheel:setPage(mainPage)

function pings.bababoy16()
   sounds:playSound("music_disc.pigstep", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Pigstep - Lena Raine")
    :item("minecraft:music_disc_pigstep")
    :hoverColor(1,0,1)
    :onLeftClick(pings.bababoy16)

function pings.bababoy10()
   sounds:playSound("music_disc.otherside", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("Otherside - Lena Raine")
    :item("minecraft:music_disc_otherside")
    :hoverColor(1,0,1)
    :onLeftClick(pings.bababoy10)

function pings.bababoy100()
   sounds:playSound("music_disc.5", player:getPos(),5,1,false)
end
local action = mainPage:newAction()
    :title("GEGGISETERNAL")
    :item("minecraft:coal_block")
    :hoverColor(9,9,9)
    :onLeftClick(pings.bababoy100)
