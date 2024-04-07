local funcs = {}

function calcTileOrigin(worldOrigin, tileArray, tileSize)
    local x = worldOrigin.x
    local y = worldOrigin.y
    local z = worldOrigin.z

    x = x + (tileArray.x * 5) + tileArray.x

    return vec(x, y, z)
end

function clone(cornerOne, cornerTwo, destination)
    host:sendChatCommand("clone " ..  
        cornerOne.x .. " " .. cornerOne.y .. " " .. cornerOne.z .. " " .. 
        cornerTwo.x .. " " .. cornerTwo.y .. " " .. cornerTwo.z .. " " .. 
        destination.x .. " " .. destination.y .. " " .. destination.z
    )
end

function putOnGrid(cornerOne, cornerTwo, tileSlot, tileSize, worldOrigin)
    local dest = worldOrigin + vec(-1 * (tileSlot.x * tileSize.x), 1, tileSlot.y * tileSize.y)

    log(cornerOne, cornerTwo, dest)

    clone(cornerOne, cornerTwo, dest)
end

function funcs:generate(tileArray, tileSize, origin, worldSize)
    log("Generating:")
    log("Tile Array Size: " .. tostring(tileArray))
    log("Size: " .. tostring(tileSize))
    log("Origin: " .. tostring(origin))
    log("World Size: " .. tostring(worldSize))

    local tileOrigin = calcTileOrigin(origin, tileArray, tileSize)

    local tiles = {}

    for x = 0, tileArray.x-1 do
        for y = 0, tileArray.y-1 do
            local tileX = (tileOrigin.x - (x + (x * tileSize.x)))
            local tileY = (tileOrigin.y - (y + (y * tileSize.y)))
            log("Tile at (" .. tostring(tileX) .. ", " .. tostring(tileOrigin.y) .. ", " .. tostring(tileY) .. ")")
            table.insert(tiles, vec(tileX, tileY))
        end
    end

    log(tileOrigin)

    for x = 1, worldSize.x do
        for y = 0, worldSize.y-1 do
            local tile = tiles[math.random(1, #tiles)]

            local cornerOne = vec(tile.x, tileOrigin.y, tile.y)
            local cornerTwo = vec(tile.x - tileSize.x, tileOrigin.y + tileSize.z, tile.y - tileSize.y + 1)
            local cloneTo = vec(origin.x - tileSize.x, origin.y + 1, origin.z)
            putOnGrid(cornerOne, cornerTwo, vec(x, y), tileSize, origin)
        end
    end
end

return funcs