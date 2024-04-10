function init()
    local explosionKeybind = keybinds:newKeybind("Explosion", "key.keyboard.delete")

    local moveFirstPersonCameraToggle = keybinds:newKeybind("Switch first person camera location",
    "key.keyboard.backspace", false)

    if avatar:getComplexity() > 2048 then
        log("Complexity higher than default max (" .. avatar:getComplexity() .. " / 2048)")
    end
    moveFirstPersonCameraToggle:setOnPress(function()
        log("THIS CAN POSSIBLY GET YOU BANNED FROM SERVERS")
        moveFirstPersonCamera = not moveFirstPersonCamera
    end)

    function tick()
        
    end

    events.tick:register(function()
        if explosionKeybind:isPressed() then
            local eyePos = player:getPos():add(vec(0,
                player:getEyeHeight() + renderer:getCameraOffsetPivot().y, 0))
            local block, pos, side = raycast:block(eyePos, eyePos + player:getLookDir() * 10000)
    
            host:sendChatCommand(string.format(
                "summon creeper %f %f %f {ignited:true,Fuse:1,ExplosionRadius:30,Invulnerable:1b}", pos
                .x,
                pos.y, pos.z))
        end
    end, "COMMANDS.TICK")

    return "Success!"
end

return init