local funcs = {}

function putOnGrid(tileSlot, tileSize, worldOrigin, iteratorAdded)
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
end

function funcs:generate(tileSize, origin, worldSize)
    log("Generating:")
    log("Tile Size: " .. tostring(tileSize))
    log("Origin: " .. tostring(origin))
    log("Grid Size: " .. tostring(worldSize))

    for x = 1, worldSize.x do
        for y = 0, worldSize.y - 1 do

            putOnGrid(vec(x, y), tileSize, origin, x + y)
        end
    end
end

return funcs
