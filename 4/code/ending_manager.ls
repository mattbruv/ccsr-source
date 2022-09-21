property itemSprites, itemLocs, wrongSprites, myTime, myWait, numSuccess, numTrys, selectedItems
global gItemLog, gSoundManager

on new me, theItems
  itemSprites = [28, 29, 30, 31, 32]
  itemLocs = [point(111, 157), point(158, 157), point(207, 157), point(257, 157), point(303, 157)]
  wrongSprites = [34, 35, 36, 37, 38]
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
    correct(me, theItem)
    if checkUsefull(me, theItem) then
      numSuccess = numSuccess + 1
      correct(gSoundManager)
    else
      incorrect(me, theItem)
      incorrect(gSoundManager)
    end if
    deleteAt(selectedItems, 1)
  end if
  return theLabel
end

on incorrect me, theMember
  theSprite = getAt(wrongSprites, numTrys)
  sprite(theSprite).loc = getAt(itemLocs, numTrys)
  sprite(theSprite).locV = sprite(theSprite).locV - 10
  sprite(theSprite).member = theMember
end

on correct me, theMember
  theSprite = getAt(itemSprites, numTrys)
  sprite(theSprite).loc = getAt(itemLocs, numTrys)
  sprite(theSprite).locV = sprite(theSprite).locV - 10
  sprite(theSprite).member = theMember
end

on checkUsefull me, theItem
  case 1 of
    theItem = "dexter":
      if numTrys = 1 then
        usefull = 1
      end if
    theItem = "chicken":
      if numTrys = 2 then
        usefull = 1
      end if
    theItem = "courage":
      if numTrys = 3 then
        usefull = 1
      end if
    theItem = "baboon":
      if numTrys = 4 then
        usefull = 1
      end if
    theItem = "edd":
      if numTrys = 5 then
        usefull = 1
      end if
  end case
  return usefull
end

on determineEnd me
  clearSounds(gSoundManager)
  case 1 of
    numSuccess = 5:
      theLabel = "win"
    otherwise:
      theLabel = "lose"
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
    theSprite = getAt(wrongSprites, n)
    set the loc of sprite theSprite to point(-1000, -1000)
    set the member of sprite theSprite to member("blank")
  end repeat
end
