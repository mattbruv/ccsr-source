global gEndingManager

on exitFrame
  theReturn = gotItem(gEndingManager)
  if not (theReturn = 0) then
    go(theReturn)
  else
    go(the frame)
  end if
end
