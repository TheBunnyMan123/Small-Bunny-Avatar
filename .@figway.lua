if not host:isHost() then return end

local options = {
    death_waypoints = true,
    hover_time = 5,
    menu_open_time = 5,
    gui_scale = 1.5, -- scale of the markers and menus
    slider_length = 20, -- number of characters sliders should use
    icons = { -- default icons
        default = "◆",
        hover = "◇",
        death = "☠",
    },
    sounds = {
        open = sounds["block.bamboo.hit"]:pitch(1.5):subtitle("Menu opened"),
        close = sounds["block.bamboo.hit"]:pitch(1):subtitle("Menu closed"),
        scroll = sounds["block.bamboo.break"]:pitch(6):subtitle("Menu scrolled"),
        scroll_end = sounds["block.bamboo.break"]:pitch(20):subtitle("Menu scrolled to end"),
        ranged_value = sounds["block.bamboo.break"]:subtitle("Value scrolled"),
        click = sounds["block.bamboo.break"]:pitch(1):subtitle("Button clicked"),
        new_waypoint = sounds["item.lodestone_compass.lock"]:pitch(1.5):subtitle("Waypoint created"),
        teleport = sounds["entity.illusioner.mirror_move"]:pitch(0.6):subtitle("Teleported to waypoint"),
    },
    world = (client.getServerData().ip or client.getServerData().name):gsub("[^%w._-]", "_"), -- unique string for this world, used for saving waypoints.
    icon_list = { -- list of icons to choose from when in the context menu. Strings are single icons. Tables are unselected/selected pairs.
        {"◆","◇"},"▶",{"▲","△"},"⛏","🗡","🏹","🪓","🔱","⚔","🔥","🌊","⚓",
        "🧪","✂","🍖","🔔","⚑","⛨","☠","◎",{"★","☆"},
        ":skull:",":axe:",":minecraft:",":pig:",":sheep:",":fire:",":lua:",":slime_boing:",{":banana:",":banana_rotata_y:"},{":among:",":among_dead:"},{":@gn:",":@scarlet:"},
        "ඞ","☭","☸",
        "♜","⚒","▣",
    },
}


---------- Saving
local waypoints = {}
local function saveWaypoints()
    local to_save = {}
    for dimension, dimension_waypoints in pairs(waypoints) do
        to_save[dimension] = {}
        for name, waypoint in pairs(dimension_waypoints) do
            to_save[dimension][name] = { 
                pos = waypoint.pos, 
                colour = waypoint.colour, 
                dimension = waypoint.dimension,
                icon = waypoint.icon,
                target = waypoint.target
            }
        end
    end
    local old = config:getName()
    config:setName("figway-"..options.world)
    config:save("waypoints", to_save)
    config:setName(old)
end


---------- Element object
---A single element.
---@class Element
---@field name string
---@field click function
---@field scroll function
---@field part ModelPart
---@field tasks table
local Element = {
    name = "",
    click = nil,
    scroll = nil,
    part = nil,
    tasks = {
        text = nil,
    },
}
Element.__index = Element

function Element:new(menu, name, click)
    local self = setmetatable({}, Element)
    self.menu = menu
    self.name = name
    self.click = click
    self.tasks = {
        text = self.menu.part:newText("figway_element-" .. self.name):outline(true):shadow(true):light(15,15):pos(vec(6,-#self.menu.elements*8,0):add(self.menu.text_offset),0),
    }
    return self
end

function Element:render(selected, percent_open)
    local style = selected and options.icons.default .. " §r§l" or options.icons.hover .. " §7"
    style = self.locked and "" or style
    if percent_open < 1 then
        local length = #self.name
        local substring = self.name:sub(1, math.floor(length * percent_open))
        self.tasks.text:text(style .. substring)
    else
        self.tasks.text:text(style .. self.name) 
    end
end

function Element:remove()
    self.tasks.text:remove()
    self = nil
end


---------- Menu object
---A scrollable list of elements.
---@class Menu
---@field elements Element[]
---@field selected number
---@field part ModelPart
---@field text_offset Vector3
---@field open_time number
local Menu = {
    elements = {},
    selected = 1,
    part = nil,
    text_offset = vec(0,0,0),
    open_time = 0,
}
Menu.__index = Menu

local scroll_registry = {}
local click_registry = {}
local menu_open = false
function Menu:new(part, text_offset)
    menu_open = true
    local self = setmetatable({}, Menu)
    self.part = part
    self.text_offset = text_offset or self.text_offset
    self.elements = {}
    scroll_registry[self] = function(dir) return self:scroll(dir) end
    click_registry[self] = function(state) return self:click(state) end
    return self
end

function Menu:newButton(name, click)
    local element = Element:new(self, name, click)
    self.elements[#self.elements+1] = element
    return element
end

function Menu:newText(name)
    local element = Element:new(self, name)
    function element:render(selected)
        local style = selected and options.icons.default .. " §r§l" or options.icons.hover .. " §7"
        style = self.locked and "" or style
        self.tasks.text:text(style .. self.name) 
    end
    self.elements[#self.elements+1] = element
    return element
end

function Menu:newSlider(name, value, min, max, step, callback)
    local element = Element:new(self, name)
    element.value = value
    element.min = min
    element.max = max
    element.step = step
    local function steppedBar()
        local bar = ""
        for i = 1, math.floor((element.value - element.min)/(element.max - element.min) * options.slider_length) do
            bar = bar .. "§a|"
        end
        for i = 1, options.slider_length - math.floor((element.value - element.min)/(element.max - element.min) * options.slider_length) do
            bar = bar .. "§7|"
        end
        return bar
    end
    function element:click()
        self.tasks.text:text(options.icons.default .. " §r§l" .. self.name .. " §7" .. steppedBar())
        return true
    end
    function element:scroll(dir)
        element.value = element.value - dir * element.step
        if element.value < element.min or element.value > element.max then
            element.value = math.clamp(element.value, element.min, element.max)
            options.sounds.scroll_end:pos(player:getPos()):pitch(element.value == element.min and 4 or 9):stop():play()
        else
            options.sounds.scroll:pos(player:getPos()):pitch(math.map(element.value, element.min, element.max, 5, 8)):stop():play()
            callback(element.value)
        end
        self.tasks.text:text(options.icons.default .. " §r§l" .. self.name .. " §7" .. steppedBar())
        return true
    end
    function element:render(selected, percent_open)
        local style = selected and options.icons.default .. " §r§l" or options.icons.hover .. " §7"
        style = self.locked and "" or style
        if percent_open < 1 then
            local length = #self.name
            local substring = self.name:sub(1, math.floor(length * percent_open))
            self.tasks.text:text(style .. substring)
            return
        end
        self.tasks.text:text(style .. self.name .. " " .. steppedBar())
    end
    self.elements[#self.elements+1] = element
    return element
end

function Menu:newCarousel(name, list, current, callback)
    local reverse_list = {}
    for key, value in pairs(list) do
        reverse_list[value] = key
    end
    local element = Element:new(self, name)
    element.list = list
    element.selected = reverse_list[current] or 1
    -- show the next two and previous two
    local function drawList()
        local text = ""
        for i = element.selected - 2, element.selected + 2 do
            if element.list[i] then
                local icon = element.list[i]
                if type(icon) == "table" then
                    icon = i == element.selected and icon[2] or icon[1]
                end
                text = text .. (i == element.selected and "§a" or "§7") .. icon .. " "
            else
                text = text .. "§8—"
            end
        end
        return text
    end
    function element:click()
        self.tasks.text:text(options.icons.default .. " §r§l" .. self.name .. " §7" .. drawList())
        return true
    end
    function element:scroll(dir)
        element.selected = element.selected - dir
        if element.selected < 1 or element.selected > #element.list then
            element.selected = element.selected + dir
            options.sounds.scroll_end:pos(player:getPos()):stop():play()
        else
            options.sounds.scroll:pos(player:getPos()):stop():play()
            callback(element.list[element.selected])
        end
        self.tasks.text:text(options.icons.default .. " §r§l" .. self.name .. " §7" .. drawList())
        return true
    end
    function element:render(selected, percent_open)
        local style = selected and options.icons.default .. " §r§l" or options.icons.hover .. " §7"
        style = self.locked and "" or style
        if percent_open < 1 then
            local length = #self.name
            local substring = self.name:sub(1, math.floor(length * percent_open))
            self.tasks.text:text(style .. substring)
            return
        end
        self.tasks.text:text(style .. self.name .. " " .. drawList())
    end
    self.elements[#self.elements+1] = element
    return element
end

function Menu:tick()
    self.open_time = math.clamp(self.open_time + 1, 0, options.menu_open_time)
end

function Menu:render(delta)
    for i, element in pairs(self.elements) do
        element:render(i == self.selected, (self.open_time + delta)/options.menu_open_time)
    end
end

function Menu:click(state)
    if state == 1 then
        self.clicking = true 
        options.sounds.click:pos(player:getPos()):stop():play()
        self.elements[self.selected]:click()
        return true
    elseif state == 0 then
        self.clicking = false
        return true
    end
end

function Menu:scroll(dir)
    if self.clicking and self.elements[self.selected].scroll then
        self.elements[self.selected]:scroll(dir)
        return true
    end
    self.selected = self.selected + dir
    local element = self.elements[self.selected]
    if self.selected < 1 or self.selected > #self.elements or not element or element.locked then
        self.selected = self.selected - dir
        options.sounds.scroll_end:pos(player:getPos()):stop():play()
    else
        options.sounds.scroll:pos(player:getPos()):stop():play()
    end
    return true
end

function Menu:clear()
    for _, element in pairs(self.elements) do
        element:remove()
    end
    self.elements = {}
end

function Menu:remove()
    menu_open = false
    for _, element in pairs(self.elements) do
        element:remove()
    end
    scroll_registry[self] = nil
    click_registry[self] = nil
    self = nil
end

function events.MOUSE_SCROLL(dir)
    dir = math.sign(dir)
    for _, scroll in pairs(scroll_registry) do
        if scroll(-dir) then
            return true
        end
    end
end

function events.MOUSE_PRESS(_, state)
    for _, click in pairs(click_registry) do
        if click(state) then
            return true
        end
    end
end


---------- Waypoint object
---@class Waypoint
---@field name string
---@field pos Vector3
---@field colour string #rrggbb
---@field icon string|table
local Waypoint = {
    name = "",
    pos = vec(0,0,0),
    colour = "#00ff00",
    hovering = false,
    hover_time = 0,
    distance = 0,
    pinned = false,
    tasks = {}
}
Waypoint.__index = Waypoint

local figway_enabled = true

local world_part = models:newPart("figway_world", "WORLD")
function Waypoint:new(name, pos, dimension)
    local self = setmetatable({}, Waypoint)
    self.name = tostring(name)
    self.pos = pos
    self.dimension = dimension
    self.part = world_part:newPart("waypoint-" .. name, "WORLD"):pos(pos*16)
    local dimensions = client.getTextDimensions(options.icons.default)
    self.text_offset = vec(-dimensions.x/2, dimensions.y/2, 0)
    self.tasks = {
        name = self.part:newText("waypoint-name-" .. name):pos(vec(6,0,0):add(self.text_offset)):outline(true):shadow(true):alignment("RIGHT"):light(15,15),
        icon = self.part:newText("waypoint-icon-" .. name):pos(self.text_offset):outline(true):shadow(true):alignment("RIGHT"):light(15,15),
        distance = self.part:newText("waypoint-distance-" .. name):pos(self.text_offset):outline(true):shadow(true):alignment("LEFT"):light(15,15),
    }
    return self
end

function Waypoint:load(name, data)
    local waypoint = Waypoint:new(name, data.pos)
    for key, value in pairs(data) do
        waypoint[key] = value
    end
    return waypoint
end

function Waypoint:tick()
    if self.hovering and not menu_open then
        self.hover_time = math.clamp(self.hover_time + 1, 0, options.hover_time)
        if self.hover_time == options.hover_time and not self.menu and player:isSneaking() then
            self:setupMenu()
            options.sounds.open:pos(player:getPos()):stop():play()
        elseif self.menu and not player:isSneaking() then
            self.menu:remove()
            options.sounds.close:pos(player:getPos()):stop():play()
            self.menu = nil
        end
    elseif not player:isSneaking() or not self.menu then
        if self.menu then
            self.menu:remove()
            options.sounds.close:pos(player:getPos()):stop():play()
            self.menu = nil
        else
            self.hover_time = self.hover_time - 1
        end
    end
    
    if self.menu then
        self.menu:tick()
    end
end

local function distanceString(distance)
    local units = {
        { "ℓP", 1e-35 },
        { "fm", 1e-15 },
        { "pm", 1e-12 },
        { "nm", 1e-9 },
        { "μm", 1e-6 },
        { "mm", 1e-3 },
        { "cm", 1e-2 },
        { "m",  1 },
        { "km", 1e3 },
        { "Mm", 1e6 },
        { "Gm", 1e9 },
        { "Tm", 1e12 },
        { "Pm", 1e15 },
        { "Em", 1e18 },
        { "Zm", 1e21 },
        { "Ym", 1e24 },
        { "Rm", 1e27 },
        { "Qm", 1e30 },
    }
    for i = #units, 1, -1 do
        local unit = units[i][1]
        local scale = units[i][2]
        if math.abs(distance) >= scale then
            local scaled_distance = distance / scale
            local format_str
            if scaled_distance == math.floor(scaled_distance) then
                format_str = "%d%s"
            elseif scaled_distance < 10 then
                format_str = "%.1f%s"
            else
                format_str = "%.0f%s"
            end
            return string.format(format_str, scaled_distance, unit)
        end
    end
    return "what"
end

function Waypoint:renderUI(delta)
    local text = ""
    local distance_text = ""
    local text_length = #self.name
    if (self.menu and self.hovering) or (self.menu) or (not menu_open and self.hovering) then
        text = (self.name.." "):sub(1, math.floor(text_length * math.clamp((self.hover_time + delta - 1)/(options.hover_time - 1), 0, 1)))
        local distance = distanceString(self.distance)
        distance_text = (" "..distance):sub(1, math.floor((#distance + 1) * math.clamp((self.hover_time + delta - 1)/(options.hover_time - 1), 0, 1)))
    elseif self.hover_time > 0 then
        local distance = distanceString(self.distance)
        text = (self.name.." "):sub(1, math.floor(text_length * math.clamp((self.hover_time - delta)/(options.hover_time), 0, 1)))
        distance_text = (" "..distance):sub(1, math.floor((#distance + 1) * math.clamp((self.hover_time - delta)/(options.hover_time), 0, 1)))
    end
    if self.menu then
        distance_text = ""
    end
    self.tasks.icon:text(self.menu and "" or '[{"text":"'..self:getIcon()..'", "color":"'..(self.menu and "white" or self.colour)..'"}]')
    self.tasks.name:text('[{"text":"'..(text:gsub('["\\\b\f\n\r\t]', { ['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }))..' "}]')
    self.tasks.distance:text('[{"text":"'..distance_text..'"}]')
end

function Waypoint:render(delta, player_rot)
    if self.target then
        if self._target then
            self.pos = self._target:getPos(delta):add(0,self._target:getBoundingBox().y)
            self.part:pos(self.pos*16)
        else
            self._target = world.getEntity(self.target)
        end
    end
    self:renderUI(delta)
    self.part:scale(0.5 * self.distance/6)
    self.part:offsetScale(math.lerp(self.part:getOffsetScale(), (self.hover_time > 1 and 0.6 or 1) * options.gui_scale, 0.1))
    self.part:rot(player_rot.x, -player_rot.y, 0)
    self.part:matrix(self.part:getPositionMatrix() * matrices.mat4() * (1 / (self.distance) * (self.hovering and 0.1 or 0.25)))
    if self.menu then
        self.menu:render(delta)
    end
end

function Waypoint:setupMenu()
    self.menu = self.menu or Menu:new(self.part, self.text_offset)
    local display = nil
    local function updateDisplay()
        display.name = '{"text":"'..self:getIcon()..'","color":"'..self.colour..'"}'
        display.tasks.text:pos(8,-8,0):scale(3):alignment("RIGHT")
        saveWaypoints()
    end
    if player:getPermissionLevel() >= 2 then
        self.menu:newButton("Teleport", function() 
            host:sendChatCommand("/tp " .. math.floor(self.pos.x) .. " " .. math.floor(self.pos.y) .. " " .. math.floor(self.pos.z)) 
            options.sounds.teleport:pos(player:getPos()):attenuation(9999):stop():play()
        end)
    end
    self.menu:newButton("Hide", function()
        self:hide()
        logJson("§2[Figway] §7Hid waypoint §a§l" .. self.name .. "§7. Use §a§l/figway show "..self.name.."§7 to reveal, or §a§l/figway show§7 to reveal all.\n")
    end)
    self.menu:newButton("Copy pos", function() 
        host:setClipboard(math.floor(self.pos.x) .. " " .. math.floor(self.pos.y) .. " " .. math.floor(self.pos.z)) 
    end)
    self.menu:newCarousel("Icon", options.icon_list, self.icon, function(icon) 
        self.icon = icon
        updateDisplay()
        saveWaypoints()
    end)
    self.menu:newButton("Set colour", function() 
        self.menu:clear()
        self.menu.selected = 1
        self.menu:newButton("Back", function()
            self.menu:clear()
            self:setupMenu()
        end)
        local colour = vectors.rgbToHSV(vectors.hexToRGB(self.colour))
        local function setColour()
            self.colour = "#" .. vectors.rgbToHex(vectors.hsvToRGB(colour.x, colour.y, colour.z))
            updateDisplay()
        end
        self.menu:newSlider("H", colour.x, 0, 1, 0.025, function(value)
            colour.x = value
            setColour()
        end)
        self.menu:newSlider("S", colour.y, 0, 1, 0.05, function(value)
            colour.y = value
            setColour()
        end)
        self.menu:newSlider("V", colour.z, 0, 1, 0.05, function(value)
            colour.z = value
            setColour()
        end)
        setColour()
        display = self.menu:newText("Icon Display")
        display.locked = true
    end)
    self.menu:newButton("Share", function() 
        self:share() 
    end)
    self.menu:newButton("Remove", function() 
        self:remove()
    end)
    display = self.menu:newText("Icon Display")
    display.locked = true
    updateDisplay()
end

function Waypoint:hide()
    self.hidden = true
    if self.menu then
        self.menu:remove()
        self.menu = nil
    end
    self.part:visible(false)
    saveWaypoints()
end

function Waypoint:show()
    self.hidden = false
    self.part:visible(true)
    saveWaypoints()
end

function Waypoint:setPos(x, y, z)
    local pos = x
    if type(pos) == "number" then
        pos = vec(x, y, z)
    end
    self.pos = pos
    self.part:pos(pos*16)
    saveWaypoints()
end

function Waypoint:setColour(colour)
    self.colour = colour
    saveWaypoints()
end Waypoint.setColor = Waypoint.setColour

function Waypoint:getIcon()
    local icon = self.icon or options.icons.default
    if type(icon) == "table" then
        icon = self.hovering and icon[2] or icon[1]
    end
    return icon
end

---Sets the icon of the waypoint. If a table is given, the first icon is used when unselected, and the second is used when selected.
---@param icon string|table
function Waypoint:setIcon(icon)
    self.icon = icon
    saveWaypoints()
end

---Shares the waypoint as a chat message.
function Waypoint:share()
    local encoded = toJson({
        dimension = world.getDimension(),
        name = self.name,
        colour = self.colour,
        pos = { self.pos:copy():floor():unpack() },
        icon = self.icon,
        target = self.target,
    })
    host:sendChatMessage("figway-waypoint"..encoded)
end

---Removes the waypoint, closing its menu and deleting it from all lists.
function Waypoint:remove()
    for _, task in pairs(self.tasks) do
        task:remove()
    end
    if self.menu then
        self.menu:remove()
    end
    world_part:removeChild(self.part)
    waypoints[self.dimension][self.name] = nil
    self = nil
    saveWaypoints()
end


---------- API
local api = {}

---Add the waypoint `name` at `pos` in `dimension`. If a waypoint by that name already exists in the dimension, overwrites it.
---If `target` is an Entity, the waypoint will automatically update its position to the entity's location.
---Returns a waypoint object.
---@param dimension string
---@param name string
---@param pos Vector3
---@return Waypoint
function api.add(dimension, name, pos)
    if waypoints[dimension] and waypoints[dimension][name] then
        waypoints[dimension][name]:remove()
    end
    local waypoint = Waypoint:new(name, pos, dimension)
    waypoints[dimension] = waypoints[dimension] or {}
    waypoints[dimension][name] = waypoint
    saveWaypoints()
    return waypoint
end

---Load a waypoint from the JSON string `data`.
---Returns a waypoint object.
---@param data string
---@return Waypoint
function api.load(data)
    data.pos = type(data.pos) == "table" and vec(table.unpack(data.pos)) or data.pos
    local waypoint = Waypoint:load(data.name, data)
    waypoints[waypoint.dimension] = waypoints[waypoint.dimension] or {}
    waypoints[waypoint.dimension][waypoint.name] = waypoint
    saveWaypoints()
    return waypoint
end

---Track the entity `entity` with the waypoint `name`.
---The waypoint will automatically update its position to the entity's location.
---Returns a waypoint object.
---@param name string
---@param entity Entity
---@return Waypoint
function api.track(name, entity)
    local waypoint = api.add(world.getDimension(), name, entity:getPos())
    waypoint.target = entity:getUUID()
    waypoint.pos = entity:getPos()
    saveWaypoints()
    return waypoint
end

---Get the waypoint `name` in `dimension`, or a list of all waypoints in `dimension` if `name` is nil.
---@param dimension string
---@param name string
---@return Waypoint
---@overload fun(dimension: string) : table<string, Waypoint>
function api.get(dimension, name)
    if name then
        return waypoints[dimension] and waypoints[dimension][name]
    else
        return waypoints[dimension]
    end
end

---Remove the waypoint `name` from `dimension`.
---@param dimension string
---@param name string
---@return boolean success
function api.remove(dimension, name)
    if waypoints[dimension] and waypoints[dimension][name] then
        waypoints[dimension][name]:remove()
        waypoints[dimension][name] = nil
        saveWaypoints()
        return true
    end
    return false
end

---Hide the waypoint `name` in `dimension`, all waypoints in `dimension`, or all waypoints in every dimension.
---Hiding all waypoints also disables Figway's tick and render loops.
---@param dimension string?
---@param name string?
---@overload fun(dimension: string)
---@overload fun()
function api.hide(dimension, name)
    if dimension and name then
        if waypoints[dimension] and waypoints[dimension][name] then
            waypoints[dimension][name]:hide()
        end
    elseif dimension then
        for _, waypoint in pairs(waypoints[dimension] or {}) do
            waypoint:hide()
        end
    else
        figway_enabled = false
        for _, dimension in pairs(waypoints) do
            for _, waypoint in pairs(dimension) do
                waypoint:hide()
            end
        end
    end
end

---Show the waypoint `name` in `dimension`, all waypoints in `dimension`, or all waypoints in every dimension.
---Showing a waypoint will re-enable Figway if it was previously disabled.
---@param dimension string?
---@param name string?
---@overload fun(dimension: string)
---@overload fun()
function api.show(dimension, name)
    figway_enabled = true
    if dimension and name then
        if waypoints[dimension] and waypoints[dimension][name] then
            waypoints[dimension][name]:show()
        end
    elseif dimension then
        for _, waypoint in pairs(waypoints[dimension] or {}) do
            waypoint:show()
        end
    else
        for _, dimension in pairs(waypoints) do
            for _, waypoint in pairs(dimension) do
                waypoint:show()
            end
        end
    end
end


---------- Loading
local function loadWaypoints()
    local old = config:getName()
    config:setName("figway-"..options.world)
    local to_load = config:load("waypoints")
    config:setName(old)
    if to_load then
        for dimension, dimension_waypoints in pairs(to_load) do
            waypoints[dimension] = {}
            for name, data in pairs(dimension_waypoints) do
                waypoints[dimension][name] = Waypoint:load(name, data)
            end
        end
    end
end


---------- Commands
local function isOperator()
    if player:getPermissionLevel() >= 2 then
        return true
    else
        logJson("§2[Figway] §cYou must be an operator to use this command.\n")
    end
end

local subcommands = {}
function subcommands.add(data)
    if data then
        if data:sub(1,1) == "{" and data:sub(-1) == "}" then
            data = parseJson(data)
            api.load(data)
            options.sounds.new_waypoint:pos(player:getPos()):stop():play()
            logJson("§2[Figway] §7Added waypoint §a§l" .. data.name .. " §7at §a§l" .. math.floor(data.pos.x) .. "§7, §a§l" .. math.floor(data.pos.y) .. "§7, §a§l" .. math.floor(data.pos.z) .. "§7 in §a§l" .. data.dimension .. "§7.\n")
            return
        end
        local dimension = world.getDimension()
        local pos = player:getPos():floor()
        api.add(dimension, data, pos)
        options.sounds.new_waypoint:pos(pos):stop():play()
        logJson("§2[Figway] §7Added waypoint §a§l" .. data .. " §7at §a§l" .. math.floor(pos.x) .. "§7, §a§l" .. math.floor(pos.y) .. "§7, §a§l" .. math.floor(pos.z) .. "§7 in §a§l" .. dimension .. "§7.\n")
    else
        logJson("§2[Figway] §cUsage: §7/figway add <name>\n")
    end
end

function subcommands.remove(name)
    if name then
        local dimension = world.getDimension()
        if waypoints[dimension] and waypoints[dimension][name] then
            api.remove(dimension, name)
            logJson("§2[Figway] §7Removed waypoint §a§l" .. name .. "§7.\n")
        else
            logJson("§2[Figway] §7Waypoint §a§l" .. name .. " §7does not exist.\n")
        end
    else
        logJson("§2[Figway] §cUsage: §7/figway remove <name>\n")
    end
end

function subcommands.list(dimension)
    dimension = dimension or world.getDimension()
    if waypoints[dimension] then
        logJson("§2[Figway] §7Waypoints in §a§l" .. dimension .. "§7:\n")
        for name, waypoint in pairs(waypoints[dimension]) do
            logJson("§2[Figway] §7- §a§l" .. name .. "§7 at §a§l" .. math.floor(waypoint.pos.x) .. "§7, §a§l" .. math.floor(waypoint.pos.y) .. "§7, §a§l" .. math.floor(waypoint.pos.z) .. "§7.\n")
        end
    else
        logJson("§2[Figway] §7No waypoints in §a§l" .. dimension .. "§7.\n")
    end
end

function subcommands.hide(name)
    local dimension = world.getDimension()
    if name then
        if waypoints[dimension] and waypoints[dimension][name] then
            waypoints[dimension][name]:hide()
            logJson("§2[Figway] §7Hid waypoint §a§l" .. name .. "§7. Use §a§l/figway show§7 to reveal.\n")
        else
            logJson("§2[Figway] §7Waypoint §a§l" .. name .. " §7does not exist.\n")
        end
    else
        for _, waypoint in pairs(waypoints[dimension] or {}) do
            waypoint:hide()
        end
        logJson("§2[Figway] §7Hid all waypoints. Use §a§l/figway show§7 to reveal.\n")
    end
end

function subcommands.show(name)
    local dimension = world.getDimension()
    if name then
        if waypoints[dimension] and waypoints[dimension][name] then
            waypoints[dimension][name]:show()
            logJson("§2[Figway] §7Revealed waypoint §a§l" .. name .. "§7.\n")
        else
            logJson("§2[Figway] §7Waypoint §a§l" .. name .. " §7does not exist.\n")
        end
    else
        for _, waypoint in pairs(waypoints[dimension] or {}) do
            waypoint:show()
        end
        logJson("§2[Figway] §7Revealed all waypoints. Use §a§l/figway hide§7 to hide.\n")
    end
end

function subcommands.tp(name)
    if not isOperator() then return end
    if name then
        local dimension = world.getDimension()
        if waypoints[dimension] and waypoints[dimension][name] then
            host:sendChatCommand("/tp " .. math.floor(waypoints[dimension][name].pos.x) .. " " .. math.floor(waypoints[dimension][name].pos.y) .. " " .. math.floor(waypoints[dimension][name].pos.z))
            logJson("§2[Figway] §7Teleported to §a§l" .. name .. "§7.\n")
        else
            logJson("§2[Figway] §7Waypoint §a§l" .. name .. " §7does not exist.\n")
        end
    else
        logJson("§2[Figway] §cUsage: §7/figway tp <name>\n")
    end
end

function subcommands.import(name)
    if name then
        local old = config:getName()
        config:setName("figway-"..name)
        local new_waypoints = config:load("waypoints")
        config:setName(old)
        if new_waypoints then
            for dimension, dimension_waypoints in pairs(new_waypoints) do
                waypoints[dimension] = waypoints[dimension] or {}
                for name, data in pairs(dimension_waypoints) do
                    if waypoints[dimension][name] then
                        waypoints[dimension][name]:remove()
                    end
                    waypoints[dimension][name] = Waypoint:load(name, data)
                end
            end
            saveWaypoints()
            logJson("§2[Figway] §7Imported waypoints from §a§l" .. name .. "§7.\n")
        else
            logJson("§2[Figway] §7No waypoints found for §a§l" .. name .. "§7.\n")
        end
    else
        logJson("§2[Figway] §cUsage: §7/figway import <server ip>\n")
    end
end

function subcommands.track()
    local function tryTrack()
        local entity = player:getTargetedEntity()
        if entity then
            api.track(entity:getName(), entity)
            options.sounds.new_waypoint:pos(player:getPos()):stop():play()
            logJson("§2[Figway] §7Now tracking §a§l" .. entity:getName() .. "§7.\n")
            return true
        end
    end
    
    if tryTrack() then
        return
    end

    logJson("§2[Figway] §7Entered tracking mode! Look at an entity to begin tracking it.\n")
    events.TICK:register(function()
        if tryTrack() then
            events.TICK:remove("figway.tracking")
        end
    end, "figway.tracking")
end

function subcommands.share(name)
    if name then
        local dimension = world.getDimension()
        if waypoints[dimension] and waypoints[dimension][name] then
            waypoints[dimension][name]:share()
        else
            logJson("§2[Figway] §7Waypoint §a§l" .. name .. " §7does not exist.\n")
        end
    else
        logJson("§2[Figway] §cUsage: §7/figway share <name>\n")
    end
end

local function promptNew(owner, data, json_data, message)
    local accept = { 
        text = "§a           [Accept]", 
        clickEvent = { action = "suggest_command", value = "/figway add " .. json_data }, 
        hoverEvent = { action = "show_text", value = "§aClick to accept this waypoint." }
    }
    if waypoints[data.dimension] and waypoints[data.dimension][data.name] then
        accept.text = "§e           [Accept]"
        accept.hoverEvent.value = "§cWARNING: §eThis will overwrite an existing waypoint with the same name."
    end
    return toJson{
        { 
            text = "§2[Figway] §7Incoming waypoint from §a§l" .. owner.text .. "§7: §a§l" .. data.name .. "§7.\n" , 
            hoverEvent = { action = "show_text", value = "§aOriginal message: §r\n" .. message } 
        },
        accept,
        { 
            text = "§c [Reject]", 
            hoverEvent = { action = "show_text", value = "§cThis button doesn't do anything, but it felt wrong to not include it." }
        },
    }, vec(0,0.2,0)
end
function events.CHAT_RECEIVE_MESSAGE(message, json)
    if message:find("figway%-waypoint") then
        local json_data = message:match("figway%-waypoint(%b{})")
        local success, data = pcall(parseJson, json_data)
        if success and data.dimension and data.name and data.pos and data.pos[1] and data.pos[2] and data.pos[3] then
            data.pos = vec(table.unpack(data.pos))
            if tostring(data.pos:copy():length()) == "Infinity" then
                logJson("§2[Figway] §7Invalid incoming waypoint (coordinates out of range).\n")
                return json, vec(0.2,0,0)
            end
            local owner = parseJson(json)
            if owner.with and owner.with[1] and owner.with[1].extra and owner.with[1].extra then
                owner = owner.with[1].extra[1]
            else
                owner = { text = "Unknown" }
            end
            return promptNew(owner, data, json_data, message)
        else
            logJson("§2[Figway] §7Invalid incoming waypoint.\n")
            return json, vec(0.2,0,0)
        end
    elseif message:find("xaero%-waypoint") then
        local name, x, y, z = message:match("xaero%-waypoint:(%w+):.-:(%-?%d+):(%-?%d+):(%-?%d+)")
        if name and x and y and z then
            local pos = vec(tonumber(x), tonumber(y), tonumber(z))
            if tostring(pos:copy():length()) == "Infinity" then
                logJson("§2[Figway] §7Invalid incoming waypoint (Xaero's) (coordinates out of range).\n")
                return json, vec(0.2,0,0)
            end
            local data = {
                dimension = world.getDimension(),
                name = name,
                pos = pos,
            }
            return promptNew({ text = "Xaero's Minimap" }, data, toJson{ dimension = data.dimension, name = data.name, pos = { data.pos:unpack() } }, message)
        else
            logJson("§2[Figway] §7Invalid incoming waypoint.\n")
            return json, vec(0.2,0,0)
        end
    elseif message:find("%b[]") and message:find("[xyz]:%-?%d+") then
        local name = message:match("name:([%w%s]+)") or "Shared Journeymap Waypoint"
        local x = message:match("x:(%-?%d+)")
        local y = message:match("y:(%-?%d+)")
        local z = message:match("z:(%-?%d+)")
        local dim = ({[-1] = "minecraft:the_nether", [0] = "minecraft:overworld", [1] = "minecraft:the_end"})[message:match("dim:(%d+)")] or world.getDimension() 
        if name and x and y and z then
            local pos = vec(tonumber(x), tonumber(y), tonumber(z))
            if tostring(pos:copy():length()) == "Infinity" then
                logJson("§2[Figway] §7Invalid incoming waypoint (coordinates out of range).\n")
                return json, vec(0.2,0,0)
            end
            local data = {
                dimension = dim,
                name = name,
                pos = pos,
            }
            return promptNew({ text = "Journeymap" }, data, toJson{ dimension = data.dimension, name = data.name, pos = { data.pos:unpack() } }, message)
        else
            logJson("§2[Figway] §7Invalid incoming waypoint.\n")
            return json, vec(0.2,0,0)
        end
    end
end

function events.CHAT_SEND_MESSAGE(message)
    if not message then return end
    if message:sub(1,7) == "/figway" then
        host:appendChatHistory(message)
        local subcommand = subcommands[message:match("^/figway (%w+)")]
        if subcommand then
            subcommand(message:match("^/figway %w+ (.+)"))
        else
            local keys = {}
            for key, _ in pairs(subcommands) do
                keys[#keys+1] = key
            end
            logJson("§2[Figway] §7Unknown command. Valid commands are: §a§l" .. table.concat(keys, "§7, §a§l") .. "§7.\n")
        end
    else
        return message
    end
end


---------- Init
local last_dimension = nil
function events.WORLD_TICK()
    if not figway_enabled or not player:isLoaded() then return end
    local current_dimension = world.getDimension()
    if current_dimension ~= last_dimension then
        last_dimension = current_dimension
        for _, dimension in pairs(waypoints) do
            for _, waypoint in pairs(dimension) do
                waypoint.part:visible(false)
            end
        end
        for _, waypoint in pairs(waypoints[current_dimension] or {}) do
            waypoint.part:visible(true)
        end
    end

    local closest_waypoint = nil
    local closest_distance = math.huge
    for _, waypoint in pairs(waypoints[current_dimension] or {}) do 
        local screen_space = vectors.worldToScreenSpace(waypoint.pos)
        local camera_space = vectors.toCameraSpace(waypoint.pos)
        waypoint.visible = math.abs(screen_space.x) < 1 and math.abs(screen_space.y) < 1 and camera_space.z > 0 and client.isHudEnabled() and not waypoint.hidden
        if waypoint.visible then
            waypoint.part:visible(true)
            local distance = screen_space[4]
            local hover_area = 0.15 * (waypoint.hovering and 1.6 or 1)
            local hovering = math.abs(screen_space.x) <= hover_area/2 and math.abs(screen_space.y) <= hover_area/2
            waypoint.distance = distance
            waypoint.hovering = false
            if hovering and screen_space.xy:length() < closest_distance then
                closest_waypoint = waypoint
                closest_distance = screen_space.xy:length()
            end
        else
            waypoint.part:visible(false)
            if waypoint.menu then
                waypoint.menu:remove()
                options.sounds.close:pos(player:getPos()):stop():play()
                waypoint.menu = nil
            end
        end
    end
    for _, waypoint in pairs(waypoints[current_dimension] or {}) do
        if waypoint.visible then
            waypoint.hovering = waypoint == closest_waypoint
            waypoint:tick()
        end
    end

    if options.death_waypoints and player:getDeathTime() == 1 then
        local waypoint = api.add(world.getDimension(), "Last Death", player:getPos():floor():add(0.5,0.5,0.5))
        waypoint:setColour("#AA0000")
        waypoint:setIcon(options.icons.death)
        options.sounds.new_waypoint:pos(player:getPos()):stop():play()
    end
end

function events.WORLD_RENDER(delta)
    if not figway_enabled or not player:isLoaded() then return end
    local player_rot = player:getRot()
    for _, waypoint in pairs(waypoints[world.getDimension()] or {}) do
        if waypoint.visible then
            waypoint:render(delta, player_rot)
        end
    end
end

loadWaypoints()

return api