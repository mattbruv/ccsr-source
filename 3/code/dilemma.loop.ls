global gameStage

on exitFrame
  if not keyPressed(RETURN) then
    go(the frame)
  else
    changeGameStage(#ENDING)
  end if
end
