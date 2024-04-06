--hide vanilla models
vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

--libs
local json = require "json-prettify"
local anims = require("JimmyAnims")
local fakeNameplate = require("nameplate")
anims(animations.model)
function tableContains(table, value)
  for i = 1,#testTable do
    if (testTable[i] == value) then
      return true
    end
  end
  return false
end
local base64='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function base64Encode(data)
    return ((data:gsub('.', function(x) 
        local r,base64='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function base64Decode(data)
    data = string.gsub(data, '[^'..base64..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(base64:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end


local function splitByChunk(text, chunkSize)
  local s = {}
  for i=1, #text, chunkSize do
      s[#s+1] = text:sub(i,i+chunkSize - 1)
  end
  return s
end

-- vars
moveFirstPersonCamera = false
swingDelay = 0
hideSkull = false
nameplateHead = '["",{"text":"${badges}"},{"text":"\n"},{"text":":rabbit: "},{"text":"Bunny","color":"#40E0D0"},{"text":" :rabbit:"}'
nameplateOther = '["",{"text":":rabbit: "},{"text":"Bunny","color":"#40E0D0"},{"text":" :rabbit: "}, {"text":"${badges}"}]'
nameplate_extra = ""
alreadyAfk = false
task = nil
blockBelowCache = {}

-- THANK YOU 5P4(4P5)
local units = {
  { base = "second", plural = "seconds", divisor = 1, decimal = 0 },
  { base = "minute", plural = "minutes", divisor = 60, decimal = 2 },
  { base = "millisecond", plural = "milliseconds", divisor = 1 / 1000, decimal = 0 },
  { base = "day", plural = "days", divisor = 60 * 60 * 24, decimal = 5 },
  { base = "business day", plural = "business days", divisor = (60 * 60 * 24) * (5/7), decimal = 5 },
  { base = "week", plural = "weeks", divisor = 60 * 60 * 24 * 7, decimal = 7 },
  { base = "milliday", plural = "millidays", divisor = 60 * 60 * 24 / 1000, decimal = 3 },
  { base = "beat", plural = "beats", divisor = 60 * 60 * 24 / 1000, decimal = 3 },
  { base = "year", plural = "years", divisor = 60 * 60 * 24 * 365.25, decimal = 8 },
  { base = "lunar year", plural = "lunar years", divisor = 60 * 60 * 24 * 365.25 / 29.53059, decimal = 8 },
  { base = "microfortnight", plural = "microfortnights", divisor = 60 * 60 * 24 * 14 / 1000000, decimal = 1 },
  { base = "leap year", plural = "leap years", divisor = 60 * 60 * 24 * 365.25 * 4, decimal = 8 },
  { base = "microcentury", plural = "microcenturies", divisor = 60 * 60 * 24 * 365.25 * 100 / 1000000, decimal = 4 },
  { base = "nanocentury", plural = "nanocenturies", divisor = 60 * 60 * 24 * 365.25 * 100 / 1000000000, decimal = 1 },
  { base = "jiffy", plural = "jiffies", divisor = 1 / 60, decimal = 0 },
  { base = "milliweek", plural = "milliweeks", divisor = 60 * 60 * 24 * 7 / 1000, decimal = 3 },
  { base = "tick", plural = "ticks", divisor = 1 / 20, decimal = 0 },
  { base = "ögonblick", plural = "ögonblick", divisor = 2, decimal = 0 },
  { base = "moment", plural = "moments", divisor = 90, decimal = 3 },
  { base = "vine", plural = "vines", divisor = 6, decimal = 1 },
  { base = "Hobbit trilogy", plural = "Hobbit trilogies", divisor = 532 * 60 * 60, decimal = 7 },
  { base = "Ash Twin cycle", plural = "Ash Twin cycles", divisor = 22 * 60, decimal = 5 },
  { base = "Quinzième", plural = "Quinzièmes", divisor = (60 * 60 * 24) / 15, decimal = 5 }
}
local unit = units[1]
local current_unit = 1

-- keybinds
local moveFirstPersonCameraToggle = keybinds:newKeybind("Switch first person camera location", "key.keyboard.backspace", false)
local ringToggle = keybinds:newKeybind("Toggle health ring", "key.keyboard.right.bracket", false)

function pings.ringToggleRemote(x)
  models.model.root.RightArm.Upper.Lower.Ring:setVisible(x)
end

function events.entity_init()
  if avatar:getComplexity() > 2048 then
    log("Complexity higher than default max ("..avatar:getComplexity().." / 2048)")
  end
  moveFirstPersonCameraToggle:setOnPress(function()
    log("THIS CAN POSSIBLY GET YOU BANNED FROM SERVERS")
    moveFirstPersonCamera = not moveFirstPersonCamera
  end)
  ringToggle:setOnPress(function()
    models.model.RightArmFP.Upper5.Lower5.Ring2:setVisible(not models.model.root.RightArm.Upper.Lower.Ring:getVisible())
    pings.ringToggleRemote(not models.model.root.RightArm.Upper.Lower.Ring:getVisible())
  end)
end

-- customization
function events.render(_,context)
  local fp = (context == "FIRST_PERSON")
  models.model.RightArmFP:setVisible(fp)
  models.model.root.RightArm:setVisible(not fp)
  models.model.root.Head.HelmetPivot:setScale(0.7,0.7,0.7)
  models.model.root.Head.HelmetItemPivot:setScale(0.75,0.75,0.75)
  models.model.root.Body.ChestplatePivot:setScale(0.7,0.7,0.7)
  models.model.root.RightArm.Upper.RightShoulderPivot:setScale(0.7,0.7,0.7)
  models.model.root.LeftArm.Upper4.LeftShoulderPivot:setScale(0.7,0.7,0.7)
  models.model.root.RightArm.Upper.Lower.RightItemPivot:setScale(0.7,0.7,0.7)
  models.model.root.LeftArm.Upper4.Lower4.LeftItemPivot:setScale(0.7,0.7,0.7)
  models.model.root.Body.LeggingsPivot:setScale(0.7,0.7,0.7)
  models.model.root.LeftLeg.Upper2.LeftLeggingPivot:setScale(0.7,0.7,0.7)
  models.model.root.RightLeg.Upper3.RightLeggingPivot:setScale(0.7,0.7,0.7)
  models.model.root.LeftLeg.Upper2.Lower2.LeftBootPivot:setScale(0.7,0.7,0.7)
  models.model.root.RightLeg.Upper3.Lower3.RightBootPivot:setScale(0.7,0.7,0.7)

  -- camera
  if renderer:isFirstPerson() then
    renderer:setOffsetCameraPivot(moveFirstPersonCamera and vec(0, -0.5, 0) or vec(0, 0, 0))
    renderer:setEyeOffset(moveFirstPersonCamera and vec(0, -0.5, 0) or vec(0, 0, 0))
  else
    renderer:setOffsetCameraPivot(0, -0.5, 0)
    renderer:setEyeOffset(0, -0.5, 0)
  end
end

function events.tick()
  --ring
  local health = player:getHealth()/player:getMaxHealth()
	models.model.root.RightArm.Upper.Lower.Ring.HealthRingHealthIndicatorReal:setColor(1-health,health,0.05)
  models.model.RightArmFP.Upper5.Lower5.Ring2.HealthRingHealthIndicatorReal2:setColor(1-health,health,0.05)

  if swingDelay > 0 then
    swingDelay = swingDelay - 1
  end
end