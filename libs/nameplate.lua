return function(root, offset, scale, text)
    local task = root:newText("nameplate")
    root:setParentType("CAMERA")
    task:setPos(offset)
    task:setText(text)
    task:setScale(scale)
    task:setAlignment("CENTER")
    task:setShadow(true)
    -- task:setOutline(true)
    -- task:setBackgroundColor(vec(0.3, 0.3, 0.3))
    return task
end