property turnedOff

on new me
  return me
end

on beginSprite me
  turnedOff = 0
end

on mouseUp me
  startGame()
end

on mouseWithin me
  if turnedOff then
    changeCursor("arrow")
  else
    changeCursor("finger")
  end if
end
