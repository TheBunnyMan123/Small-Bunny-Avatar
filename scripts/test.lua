function pings.createTestEntity(pos)
    pos = pos + vec(0, 3, 0)
    LibEntity.new("TestEntity", pos, {vec(-1, 0, -1)/16, vec(1, 2, 1)/16}):setAI("FOLLOW", models.test.World:setPos(pos * 16), "TheKillerBunny")
end

events.entity_init:register(function()
    if host:isHost() then
        pings.createTestEntity(player:getPos())
        log("test")
    end
end)