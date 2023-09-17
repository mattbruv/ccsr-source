global gInventorySprite

on new me
  return me
end

on mouseEnter
  sendSprite(gInventorySprite, #changeCursor, "finger")
end

on mouseLeave
  sendSprite(gInventorySprite, #changeCursor, "arrow")
end

on mouseUp
  sendSprite(gInventorySprite, #itemSelected, sprite(the currentSpriteNum).member.name)
end
