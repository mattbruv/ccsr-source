property turnedOff

on new me
  return me
end

on beginSprite me
  turnedOff = 0
end

on mouseUp me
  resetVars()
  useFinalData()
  turnedOff = 1
  changeCursor(me, "arrow")
  changeGameStage(#MIDDLE)
  go("game")
end

on mouseWithin me
  if turnedOff then
    changeCursor(me, "arrow")
  else
    changeCursor(me, "finger")
  end if
end

on changeCursor me, theCursor
  case 1 of
    theCursor = "arrow":
      cursor(-1)
    theCursor = "finger":
      cursor(280)
  end case
end
