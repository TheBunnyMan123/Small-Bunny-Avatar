---@class tilegen
local funcs = {}

function calcTileOrigin(worldOrigin, tileArray, tileSize)
    local x = worldOrigin.x
    local y = worldOrigin.y
    local z = worldOrigin.z

    x = x + (tileArray.x * tileSize.x) + tileArray.x

    return vec(x, y, z)
end

function clone(cornerOne, cornerTwo, destination)
    host:sendChatCommand("clone " ..
        cornerOne.x .. " " .. cornerOne.y .. " " .. cornerOne.z .. " " ..
        cornerTwo.x .. " " .. cornerTwo.y .. " " .. cornerTwo.z .. " " ..
        destination.x .. " " .. destination.y .. " " .. destination.z
    )
end

function putOnGrid(cornerOne, cornerTwo, tileSlot, tileSize, worldOrigin, iteratorAdded)
    local dest = worldOrigin + vec((-1 * (tileSlot.x * tileSize.x)) + 1, 1, tileSlot.y * tileSize.y)
    local gridDest = worldOrigin + vec(-1 * (tileSlot.x * tileSize.x), 1, tileSlot.y * tileSize.y)

    local gridCornerOne = vec((gridDest.x + tileSize.x), worldOrigin.y, gridDest.z)
    local gridCornerTwo = vec((gridDest.x + tileSize.y) - (tileSize.x - 1), worldOrigin.y,
        gridDest.z + (tileSize.y - 1))

    local gridBlock

    if iteratorAdded == 0 or iteratorAdded % 2 == 0 then
        gridBlock = " snow_block"
    else
        gridBlock = " white_concrete"
    end

    host:sendChatCommand("fill " ..
        gridCornerOne.x .. " " .. gridCornerOne.y .. " " .. gridCornerOne.z .. " " ..
        gridCornerTwo.x .. " " .. gridCornerTwo.y .. " " .. gridCornerTwo.z .. gridBlock
    )

    clone(cornerOne, cornerTwo, dest)
end

function funcs:generate(tileArray, tileSize, origin, worldSize)
    log("Generating:")
    log("Tile Array Size: " .. tostring(tileArray))
    log("Tile Size: " .. tostring(tileSize))
    log("Origin: " .. tostring(origin))
    log("World Size: " .. tostring(worldSize))

    local tileOrigin = calcTileOrigin(origin, tileArray, tileSize)

    log("Tile Origin: " .. tostring(tileOrigin))

    local tiles = {}

    for x = 0, tileArray.x - 1 do
        for y = 0, tileArray.y - 1 do
            local tileX = (tileOrigin.x - (x + (x * tileSize.x)))
            local tileY = (tileOrigin.z - (y + (y * tileSize.y)))

            local cornerOne = vec(tileX, tileOrigin.y - 1, tileY)
            local cornerTwo = vec(tileX - (tileSize.x - 1), tileOrigin.y - 1,
                tileY - (tileSize.y - 1))

            host:sendChatCommand("fill " ..
                cornerOne.x .. " " .. cornerOne.y .. " " .. cornerOne.z .. " " ..
                cornerTwo.x .. " " .. cornerTwo.y .. " " .. cornerTwo.z .. " glass"
            )

            table.insert(tiles, vec(tileX, tileY))
        end
    end

    for x = 1, worldSize.x do
        for y = 0, worldSize.y - 1 do
            local tile = tiles[math.random(1, #tiles)]

            local cornerOne = vec(tile.x, tileOrigin.y, tile.y)
            local cornerTwo = vec(tile.x - (tileSize.x - 1), tileOrigin.y + tileSize.z,
                tile.y - (tileSize.y - 1))

            putOnGrid(cornerOne, cornerTwo, vec(x, y), tileSize, origin, x + y)
        end
    end
end

return funcs
