property itemSprites, itemLocs, myTime, myWait, numSuccess, numTrys, selectedItems
global gItemLog, gSoundManager

on new me, theItems
  itemSprites = [16, 17, 18, 19, 20]
  itemLocs = [point(158, 122), point(253, 126), point(128, 88), point(288, 86), point(204, 48)]
  myWait = 1
  numSuccess = 0
  numTrys = 0
  selectedItems = []
  repeat with n = 1 to min(5, count(theItems))
    add(selectedItems, getAt(theItems, n))
  end repeat
  iniSprites(me)
  cursor(-1)
  return me
end

on iniSprites me
  howMany = count(itemSprites)
  repeat with n = 1 to howMany
    theSprite = getAt(itemSprites, n)
    sprite(theSprite).loc = point(-100, -100)
  end repeat
end

on gotItem me
  if (the ticks - myTime) / 60.0 > myWait then
    myTime = the ticks
    return popItem(me)
  end if
end

on popItem me
  theLabel = 0
  numTrys = numTrys + 1
  if selectedItems = [] then
    if numTrys <= 5 then
      incorrect(me, "wrong")
    else
      theLabel = determineEnd(me)
    end if
  else
    theItem = getAt(selectedItems, 1)
    if checkUsefull(me, theItem) then
      numSuccess = numSuccess + 1
      theLabel = "plugged." & numSuccess
      correct(me, theItem)
      deleteAt(selectedItems, 1)
    else
      theSprite = getAt(itemSprites, numTrys)
      incorrect(me, theItem)
      deleteAt(selectedItems, 1)
    end if
  end if
  return theLabel
end

on incorrect me, theMember
  incorrect(gSoundManager)
  theSprite = getAt(itemSprites, numTrys)
  sprite(theSprite).loc = getAt(itemLocs, numTrys)
  sprite(theSprite).locV = sprite(theSprite).locV - 10
  sprite(theSprite).member = theMember
end

on correct me, theMember
  correct(gSoundManager)
  theSprite = getAt(itemSprites, numTrys)
  sprite(theSprite).loc = getAt(itemLocs, numTrys)
  sprite(theSprite).locV = sprite(theSprite).locV - 10
  sprite(theSprite).member = theMember
end

on checkUsefull me, theItem
  case 1 of
    theItem = "turnip":
      usefull = 1
    theItem = "nutlog":
      usefull = 1
    theItem = "wig":
      usefull = 1
    theItem = "octo":
      usefull = 1
    theItem = "burger":
      usefull = 1
    theItem = "pineapple":
      usefull = 1
  end case
  return usefull
end

on determineEnd me
  clearSounds(gSoundManager)
  case 1 of
    numSuccess = 5:
      theLabel = "result.2"
    otherwise:
      theLabel = "result.1"
  end case
  cursor(-1)
  clearItems(me)
  return theLabel
end

on clearItems me
  howMany = count(itemSprites)
  repeat with n = 1 to howMany
    theSprite = getAt(itemSprites, n)
    set the loc of sprite theSprite to point(-1000, -1000)
    set the member of sprite theSprite to member("blank")
  end repeat
end
