local funcs = {}

function equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function calcTileOrigin(worldOrigin, tileArray, tileSize)
    local x = worldOrigin.x
    local y = worldOrigin.y
    local z = worldOrigin.z

    x = x + (tileArray.x * tileSize.x) + tileArray.x

    return vec(x, y, z)
end

function clone(cornerOne, cornerTwo, destination)
    log("clone " ..  
    cornerOne.x .. " " .. cornerOne.y .. " " .. cornerOne.z .. " " .. 
    cornerTwo.x .. " " .. cornerTwo.y .. " " .. cornerTwo.z .. " " .. 
    destination.x .. " " .. destination.y .. " " .. destination.z)

    host:sendChatCommand("clone " ..  
        cornerOne.x .. " " .. cornerOne.y .. " " .. cornerOne.z .. " " .. 
        cornerTwo.x .. " " .. cornerTwo.y .. " " .. cornerTwo.z .. " " .. 
        destination.x .. " " .. destination.y .. " " .. destination.z
    )
end

function putOnGrid(cornerOne, cornerTwo, tileSlot, tileSize, worldOrigin, empty, tileOrigin)
    local dest = worldOrigin + vec(-1 * (tileSlot.x * tileSize.x), 1, tileSlot.y * tileSize.y)

    if empty == true then
        cornerTwo = vec(dest.x - tileSize.x, tileOrigin.y + tileSize.z, dest.y - tileSize.y + 1)

        host:sendChatCommand("fill " ..  
        dest.x .. " " .. dest.y .. " " .. dest.z .. " " .. 
        cornerTwo.x .. " " .. cornerTwo.y .. " " .. cornerTwo.z .. " air"
    )
    else
        clone(cornerOne, cornerTwo, dest)
    end
end

function getSide(tile, side, tileSize, origin)
    local out 

    if side == "left" then
        out = world.getBlocks(tile.x, origin.y,  tile.y, tile.x - (tileSize.x  - 1), origin.y,  tile.y)
    elseif side == "right" then
        out = world.getBlocks(tile.x, origin.y,  tile.y + (tileSize.y  - 1), tile.x - (tileSize.x  - 1), origin.y,  tile.y + (tileSize.y  - 1))
    elseif side == "top" then
        out = world.getBlocks(tile.x - (tileSize.x  - 1), origin.y,  tile.y, tile.x - (tileSize.x  - 1), origin.y,  tile.y + (tileSize.y  - 1))
    elseif side == "bottom" then
        out = world.getBlocks(tile.x, origin.y,  tile.y, tile.x, origin.y,  tile.y + (tileSize.y  - 1))
    end

    return out
end

function funcs:generate(tileArray, tileSize, origin, worldSize)
    log("Generating:")
    log("Tile Array Size: " .. tostring(tileArray))
    log("Size: " .. tostring(tileSize))
    log("Origin: " .. tostring(origin))
    log("World Size: " .. tostring(worldSize))

    local tileOrigin = calcTileOrigin(origin, tileArray, tileSize)

    log("Tile Origin: " .. tostring(tileOrigin))

    local tiles = {}

    for x = 0, tileArray.x-1 do
        for y = 0, tileArray.y-1 do
            local tileX = (tileOrigin.x - (x + (x * tileSize.x)))
            local tileY = ((tileOrigin.y - (y + ((y * tileSize.y)))) + ((tileSize.y - 5) * 2))
            table.insert(tiles, vec(tileX, tileY))
        end
    end

    local placedTileMaps = {
        -- {
        --     left = {},
        --     right = {},
        --     top = {},
        --     bottom = {}
        -- }
    }

    for y = 0, worldSize.y-1 do
        table.insert(placedTileMaps, {})
        for x = 1, worldSize.x do

            local availableTiles = {}

            for _, v in pairs(tiles) do
                log("y", y, "x", x)
                if y == 0 then
                    if x == 1 then
                        table.insert(availableTiles, v)
                    else
                        if equals(placedTileMaps[y+1][x-1].top, {}) then
                            table.insert(availableTiles, v)
                        end
                        log(getSide(v, "right", tileSize, origin), placedTileMaps[y+1][x-1].left)
                        if equals(getSide(v, "right", tileSize, origin),placedTileMaps[y+1][x-1].left) then
                            log("yes")
                            table.insert(availableTiles, v)
                        end
                    end
                else
                    if x == 1 then
                        if equals(placedTileMaps[y][worldSize.x].top, {}) then
                            table.insert(availableTiles, v)
                        end
                        log(getSide(v, "bottom", tileSize, origin), placedTileMaps[y][x].top)
                        if equals(getSide(v, "bottom", tileSize, origin), placedTileMaps[y][x].top) then
                            log("yes")
                            table.insert(availableTiles, v)
                        end
                    else
                        if equals(placedTileMaps[y][x-1].top, {}) then
                            table.insert(availableTiles, v)
                        end
                        log(getSide(v, "bottom", tileSize, origin), placedTileMaps[y][x].top, getSide(v, "right", tileSize, origin), placedTileMaps[y+1][x-1].left, equals(getSide(v, "bottom", tileSize, origin), placedTileMaps[y][x].top) and equals(getSide(v, "right", tileSize, origin), placedTileMaps[y+1][x-1].left))
                        if equals(getSide(v, "bottom", tileSize, origin), placedTileMaps[y][x].top) and equals(getSide(v, "right", tileSize, origin), placedTileMaps[y+1][x-1].left) then
                            log("yes")
                            table.insert(availableTiles, v)
                        end
                    end
                end
            end

            log("available", availableTiles)

            if #availableTiles == 0 then
                local tile = tiles[math.random(1, #tiles)]

                table.insert(placedTileMaps[y+1], {
                    left = {},
                    right = {},
                    top = {},
                    bottom = {},
                })

                local cornerOne = vec(tile.x, tileOrigin.y, tile.y)
                local cornerTwo = vec(tile.x - tileSize.x, tileOrigin.y + tileSize.z, tile.y - tileSize.y + 1)
                putOnGrid(cornerOne, cornerTwo, vec(x, y), tileSize, origin, true, tileOrigin)
                
                goto continue
            end

            local tile = availableTiles[math.random(1, #availableTiles)]

            log(5)
            table.insert(placedTileMaps[y+1], {
                left = getSide(tile, "left", tileSize, origin),
                right = getSide(tile, "right", tileSize, origin),
                top = getSide(tile, "top", tileSize, origin),
                bottom = getSide(tile, "bottom", tileSize, origin),
            })

            -- table.insert(placedTileMaps[x], tile)

            local cornerOne = vec(tile.x, tileOrigin.y, tile.y)
            local cornerTwo = vec(tile.x - tileSize.x, tileOrigin.y + tileSize.z, tile.y - tileSize.y + 1)
            putOnGrid(cornerOne, cornerTwo, vec(x, y), tileSize, origin)
            ::continue::
        end
    end
end

return funcs