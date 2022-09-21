property inventoryState, curPage, itemOnPageMax, curNumPages, curItem, myInventory, descriptionList, selectedItemNameList, selectedItemKeyList, inventorySprite, descriptSprite, iconSprites, squareSprite, instructSprite, nextSprite, previousSprite, inventoryLoc, descriptLoc, iconLocs, instructLoc, nextLoc, previousLoc, returnWasPressed
global gInventorySprite, gSprite, gItemLog, gSoundManager, gameStage, gEndingManager

on beginSprite me
  inventorySprite = 176
  gInventorySprite = inventorySprite
  inventoryLoc = point(208, 160)
  descriptSprite = 177
  descriptLoc = point(81, 79)
  squareSprite = 178
  instructSprite = 179
  instructLoc = point(207, 251)
  previousSprite = 180
  previousLoc = point(95, 125)
  nextSprite = 181
  nextLoc = point(319, 125)
  iconSprites = [182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197]
  iconLocs = [point(141, 109), point(186, 109), point(231, 109), point(274, 109), point(98, 153), point(141, 153), point(186, 153), point(230, 153), point(274, 153), point(318, 153), point(98, 197), point(141, 197), point(186, 197), point(230, 197), point(274, 197), point(318, 197)]
  itemOnPageMax = 16
  selectedItemKeyList = []
  selectedItemNameList = []
  createDescriptLIst(me)
  removeInventory(me)
  if gameStage = #ENDING then
    openInventory(me)
  end if
end

on createDescriptLIst me
  the itemDelimiter = RETURN
  tempList1 = []
  howMany = the number of items in field "inventory.descriptions"
  repeat with n = 1 to howMany
    add(tempList1, item n of field "inventory.descriptions")
  end repeat
  repeat with n = 1 to howMany
    add(tempList1, item n of field "inventory.descriptions")
  end repeat
  the itemDelimiter = ":"
  descriptionList = []
  howMany = count(tempList1)
  repeat with n = 1 to howMany
    add(descriptionList, [#key: item 1 of getAt(tempList1, n), #name: item 2 of getAt(tempList1, n), #info: item 3 of getAt(tempList1, n)])
  end repeat
end

on changePurpose me, theChange
  curPurpose = theChange
end

on exitFrame me
  case 1 of
    gameStage = #MIDDLE:
      if not sendSprite(gSprite[#player], #checkForMessage) then
        if keyPressed(RETURN) then
          if not returnWasPressed then
            returnIsPressed(me, 1)
          end if
        else
          returnWasPressed = 0
        end if
      end if
    gameStage = #ENDING:
      if keyPressed(RETURN) then
        if not returnWasPressed then
          returnWasPressed = 1
          gEndingManager = new(script("ending_manager"), selectedItemKeyList)
          removeInventory(me)
          go("anime")
        end if
      else
        returnWasPressed = 0
      end if
  end case
end

on openInventory me
  returnIsPressed(me, 0)
end

on dontOpenInventory me
  returnWasPressed = 1
end

on returnIsPressed me, requestType
  returnWasPressed = 1
  if inventoryState = "open" then
    inventoryState = "closed"
    removeInventory(me)
    sendSprite(gSprite[#player], #resetStatus)
  else
    inventoryState = "open"
    instructed = 1
    sendSprite(gSprite[#player], #disableMovement)
    showInventory(me, requestType)
  end if
end

on showInventory me, requestType
  sfx_play3(gSoundManager, #show)
  tempInventory = duplicate(gItemLog)
  howMany = the number of items in field "banned.list"
  repeat with n = 1 to howMany
    if getPos(gItemLog, item n of field "banned.list") then
      deleteAt(tempInventory, getPos(gItemLog, item n of field "banned.list"))
      howMany = howMany - 1
    end if
  end repeat
  myInventory = []
  howMany = count(tempInventory)
  curNumPages = howMany / (itemOnPageMax + 1) + 1
  repeat with n = 1 to curNumPages
    add(myInventory, [])
  end repeat
  repeat with n = 1 to howMany
    i = (n - 1) / itemOnPageMax + 1
    add(getAt(myInventory, i), getAt(tempInventory, n))
  end repeat
  curPage = curNumPages
  if curNumPages > 1 then
    sprite(nextSprite).member = "nextPage"
    sprite(nextSprite).loc = nextLoc
    sprite(nextSprite).ink = 36
    set the scriptInstanceList of sprite nextSprite to []
    add(the scriptInstanceList of sprite nextSprite, new(script("inventory.change.page")))
    sprite(previousSprite).member = "previousPage"
    sprite(previousSprite).loc = previousLoc
    sprite(previousSprite).ink = 36
    set the scriptInstanceList of sprite previousSprite to []
    add(the scriptInstanceList of sprite previousSprite, new(script("inventory.change.page")))
  end if
  sprite(inventorySprite).member = "inventory"
  sprite(inventorySprite).loc = inventoryLoc
  sprite(inventorySprite).ink = 36
  sprite(descriptSprite).member = "inventory.txt"
  sprite(descriptSprite).loc = descriptLoc
  sprite(descriptSprite).ink = 36
  put EMPTY into member("inventory.txt")
  if gameStage = #MIDDLE then
    sprite(instructSprite).member = "inventory.instruct"
    sprite(instructSprite).loc = instructLoc
    sprite(instructSprite).ink = 36
  end if
  if requestType then
    showStuff(me, #MANUAL)
  else
    showStuff(me, #AUTO)
  end if
end

on changePage me, theDirection
  if theDirection = "previousPage" then
    curPage = curPage - 1
  else
    curPage = curPage + 1
  end if
  if curPage < 1 then
    curPage = curNumPages
  else
    if curPage > curNumPages then
      curPage = 1
    end if
  end if
  showStuff(me, #MANUAL)
end

on showStuff me, theSetting
  if theSetting = #MANUAL then
    theItemNum = 1
  else
    theItemNum = count(getAt(myInventory, curPage))
  end if
  showIcons(me)
  if myInventory = [[]] then
    showNoItems(me)
  else
    if gameStage = #MIDDLE then
      showDescription(me, theItemNum)
    end if
  end if
end

on showIcons me
  clearIcons(me)
  if not (myInventory = [[]]) then
    howMany = count(getAt(myInventory, curPage))
    repeat with n = 1 to howMany
      theItem = getAt(getAt(myInventory, curPage), n)
      theSprite = getAt(iconSprites, n)
      theLoc = getAt(iconLocs, n)
      sprite(theSprite).member = theItem
      sprite(theSprite).loc = theLoc
      sprite(theSprite).locV = sprite(theSprite).locV + 15
      sprite(theSprite).ink = 36
      set the scriptInstanceList of sprite theSprite to []
      add(the scriptInstanceList of sprite theSprite, new(script("inventory.select.item")))
    end repeat
  end if
end

on itemSelected me, theItem
  case 1 of
    gameStage = #MIDDLE:
      showDescription(me, getPos(getAt(myInventory, curPage), theItem))
    gameStage = #ENDING:
      showSelectedItems(me, theItem)
  end case
  click(gSoundManager)
end

on showNoItems me
  put "You have no items." into member("inventory.txt")
  updateStage()
end

on showDescription me, theItemNum
  sprite(squareSprite).member = "inventory.square"
  sprite(squareSprite).loc = getAt(iconLocs, theItemNum)
  sprite(squareSprite).locV = sprite(squareSprite).locV + 15
  sprite(squareSprite).ink = 36
  theItem = getAt(getAt(myInventory, curPage), theItemNum)
  howMany = count(descriptionList)
  repeat with n = 1 to howMany
    if getProp(getAt(descriptionList, n), #key) = theItem then
      theDescription = getProp(getAt(descriptionList, n), #info)
      exit repeat
    end if
  end repeat
  put theDescription into member("inventory.txt")
end

on showSelectedItems me, theItem
  put EMPTY into member("inventory.txt")
  howMany = count(descriptionList)
  repeat with n = 1 to howMany
    if getProp(getAt(descriptionList, n), #key) = theItem then
      theName = getProp(getAt(descriptionList, n), #name)
      exit repeat
    end if
  end repeat
  if not getPos(selectedItemNameList, theName) then
    if not (count(selectedItemNameList) >= 5) then
      if checkUsefull(me, theName) then
        addAt(selectedItemNameList, 1, theName)
        addAt(selectedItemKeyList, 1, theItem)
      else
        add(selectedItemNameList, theName)
        add(selectedItemKeyList, theItem)
      end if
    end if
  else
    deleteAt(selectedItemNameList, getPos(selectedItemNameList, theName))
    deleteAt(selectedItemKeyList, getPos(selectedItemKeyList, theItem))
  end if
  howMany = count(selectedItemNameList)
  repeat with n = 1 to howMany
    theName = getAt(selectedItemNameList, n)
    if n > 1 then
      theName = "," & theName
    end if
    put theName after member("inventory.txt")
  end repeat
end

on removeInventory me
  thePoint = point(-100, -100)
  theMember = "blank"
  set the loc of sprite inventorySprite to thePoint
  set the member of sprite inventorySprite to theMember
  set the loc of sprite descriptSprite to thePoint
  set the member of sprite descriptSprite to theMember
  set the loc of sprite squareSprite to thePoint
  set the member of sprite squareSprite to theMember
  set the loc of sprite instructSprite to thePoint
  set the member of sprite instructSprite to theMember
  set the loc of sprite previousSprite to thePoint
  set the member of sprite previousSprite to theMember
  set the loc of sprite nextSprite to thePoint
  set the member of sprite nextSprite to theMember
  clearIcons(me)
  changeCursor(me, "arrow")
end

on clearIcons me
  thePoint = point(-100, -100)
  theMember = "blank"
  howMany = count(iconSprites)
  repeat with n = 1 to howMany
    theSprite = getAt(iconSprites, n)
    set the scriptInstanceList of sprite theSprite to []
    set the loc of sprite theSprite to thePoint
    set the member of sprite theSprite to theMember
  end repeat
end

on checkUsefull me, theItem
  case 1 of
    theItem = "gum":
      usefull = 1
    theItem = "duckTape":
      usefull = 1
    theItem = "bandAid":
      usefull = 1
    theItem = "sock":
      usefull = 1
    theItem = "scotchTape":
      usefull = 1
  end case
  return usefull
end

on changeCursor me, theCursor
  case 1 of
    theCursor = "arrow":
      cursor(-1)
    theCursor = "finger":
      cursor(280)
  end case
end
