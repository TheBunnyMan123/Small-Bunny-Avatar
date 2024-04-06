local vis = true

function events.skull_render(delta, block, item, entity, mode)
    if not block then
      if models.skull.Skull.text then
        models.skull.Skull.text:setVisible(false)
      end
      models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
      models.skull.Skull:setPos(0, -19, 0):setScale(1.55).Table:setVisible(false)
      models.skull.Skull.TheHead.Head:setVisible(false)
      models.skull.Skull["Ear 1"]:setVisible(true)
      models.skull.Skull["Ear 2"]:setVisible(true)
      return
    end
    models.skull.Skull.TheHead.Head:setVisible(true)
    if block == nil then
      return
    end
    models.skull.Skull.TheHead.Head:setVisible(vis)
    models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
    models.skull.Skull["Ear 1"]:setVisible(vis)
    models.skull.Skull["Ear 2"]:setVisible(vis)
    if block:getProperties() == nil then
      return
    end
    if block.id == "minecraft:player_wall_head" then
      models.skull.Skull.TheHead.Head:setVisible(true)
      models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
      models.skull.Skull:setPos(0, -10.1, 1.8):setScale(1).Table:setVisible(false)
    else
      if hideSkull then
        models.skull.Skull.TheHead.Head:setVisible(false)
      end
    local is_table = block:getProperties().rotation % 4 == 0
  
      models.skull.Skull
        :setPos(is_table and vec(0, 0, 0) or vec(0, -12, 0)):setScale(1)
        .Table:setVisible(is_table)
    end
  
    -- Only run main code section if enough instructions and complexity are given to skull
    if (avatar:getMaxComplexity() >= 10000) and (avatar:getMaxRenderCount() >= 150000) and (avatar:getMaxTickCount() >= 2000) then
      for _, player in pairs(world.getPlayers()) do
        if player:isSwingingArm() and swingDelay == 0 then
          swingDelay = (20*0.3)
          local pos = player:getPos()
          if (player:getTargetedBlock().id == "minecraft:player_head") or (player:getTargetedBlock().id == "minecraft:player_wall_head") then
            vis = not models.skull.Skull.TheHead.Head:getVisible()
            models.skull.Skull.TheHead.Head:setVisible(vis)
            models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
            models.skull.Skull["Ear 1"]:setVisible(vis)
            models.skull.Skull["Ear 2"]:setVisible(vis)
            hideSkull = not hideSkull
            targetPos = player:getTargetedBlock():getPos()
            -- for i = 1, 100, 1 do
            --   if player:getTargetedBlock().id == "minecraft:player_wall_head" then
            --     particles:newParticle("minecraft:large_smoke", targetPos.x + math.random(1,9)/10, targetPos.y + math.random(1,9)/10, targetPos.z + math.random(1,9)/10)
            --   else
            --     particles:newParticle("minecraft:large_smoke", targetPos.x + math.random(1,9)/10, targetPos.y + math.random(0,14)/10, targetPos.z + math.random(1,9)/10)
            --   end
            -- end
          end
        end
      end
      local blockBelow = world.getBlockState(block:getPos()-vec(0,1,0))
  
      if blockBelow.id == "minecraft:player_head" then
        -- Hide main head and show projector
        models.skull.Skull.text:setVisible(true)
        models.skull.Skull:setPos(vec(0, -12 - 8, 0)):setScale(1):setVisible(true).Table:setVisible(false)
        models.skull.Skull.TheHead.Head:setVisible(false)
        models.skull.Skull.TheHead.CommandBlockProjector:setVisible(true)
        models.skull.Skull["Ear 1"]:setVisible(false)
        models.skull.Skull["Ear 2"]:setVisible(false)
        
        -- Set variables
        local owner = blockBelow:getEntityData().SkullOwner
        local tempText
  
        -- Set string to display skull owner's name, or if name is not available, UUID, with texture if available
        if owner.Name then
          tempText = owner.Name .. '\'s Skull'
          if owner.Properties then
            if owner.Properties.textures then
              if json.parse(base64Decode(owner.Properties.textures[1].Value), true) then
                tempText = owner.Name .. '\'s Skull\n' .. json.stringify(json.parse(base64Decode(owner.Properties.textures[1].Value), true), nil, 2)
              else
                tempText = owner.Name .. '\'s Skull\n' .. base64Decode(owner.Properties.textures[1].Value)
              end
            end
          end
        elseif owner.Id then
          tempText = client:intUUIDToString(owner.Id[1],owner.Id[2],owner.Id[3],owner.Id[4]) .. '\'s Skull'
          if owner.Properties then
            if owner.Properties.textures then
              if json.parse(base64Decode(owner.Properties.textures[1].Value), true) then
                tempText = client:intUUIDToString(owner.Id[1],owner.Id[2],owner.Id[3],owner.Id[4]) .. '\'s Skull' .. '\n' .. json.stringify(json.parse(base64Decode(owner.Properties.textures[1].Value), true), nil, 2)
              else
                tempText = client:intUUIDToString(owner.Id[1],owner.Id[2],owner.Id[3],owner.Id[4]) .. '\'s Skull' .. '\n' .. base64Decode(owner.Properties.textures[1].Value)
              end
            end
          end
        end
  
        -- If tempText is not set, then stop running to prevent error
        if not tempText then
          return
        end
  
        -- Calculate how many times a line break occurs
        local count = 0
        local check
        for _, v in pairs(splitByChunk(tempText, 1)) do
          if v == "\n" then
            count = count + 1
          end
        end
  
        -- Display text
        models.skull.Skull.text:newText("text")
            :setPos(vec(0,25+(count*3),0)) -- Raise position by 25 + (3 times count)
            :setText(tempText)
            :setScale(0.3)
            :setAlignment("LEFT")
            :setShadow(true)
            :setWrap(true)
        models.skull.Skull.text:newText("text2")
            :setPos(vec(0,25+(count*3),0)) -- Raise position by 25 + (3 times count)
            :setText(tempText)
            :setScale(0.3)
            :setAlignment("LEFT")
            :setShadow(true)
            :setWrap(true)
            :setRot(0, 180, 0) -- Flip along y axis to be viewed from other side
      else
        if models.skull.Skull.text then
          models.skull.Skull.text:setVisible(false)
        end
      end
    else
      -- If not enough instructions and complexity are given to skull, display text requesting higher permissions
  
      -- Hide projector and show main head
      models.skull.Skull.text:setVisible(true)
      models.skull.Skull:setPos(vec(0, -12, 0)):setScale(1):setVisible(true).Table:setVisible(false)
      models.skull.Skull.TheHead.Head:setVisible(true)
      models.skull.Skull.TheHead.CommandBlockProjector:setVisible(false)
      models.skull.Skull["Ear 1"]:setVisible(true)
      models.skull.Skull["Ear 2"]:setVisible(true)
      local text2 = models.skull.Skull.text:newText("text2")
      
      -- Display text
      local txt = "This skull requires a helluva\n lot of render instructions,\n please raise my permissions!"
      models.skull.Skull.text:newText("text")
          :setPos(vec(0,30+(3*5),0))
          :setText(txt)
          :setScale(0.5)
          :setAlignment("CENTER")
          :setShadow(true)
          :setWrap(true)
      models.skull.Skull.text:newText("text2")
          :setPos(vec(0,30+(3*5),0))
          :setText(txt)
          :setScale(0.5)
          :setAlignment("CENTER")
          :setShadow(true)
          :setWrap(true)
          :setRot(0, 180, 0)
    end
  end
  