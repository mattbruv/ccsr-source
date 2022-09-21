property pSpeed, pLastMove, pSprite, pBottom, pStatus, pPocket, showingMessage, itemReceived, curPlayerMember, characterDirection, lastHorizontalDirection, frameOfAnimation
global gSpriteSet, gFirstSprite, gLastSprite, gSprite, gCurrentW, gCurrentH, gMapW, gMapH, gRoomsCopy, gRooms, gPushStatus, gSoundManager, gItemLog, gActionLog, gPlayerStartLoc, gInventorySprite

on beginSprite me
  pSprite = me.spriteNum
  pBottom = 319
  pStatus = #move
  pSpeed = 8
  pAnimNum = 1
  pLastMove = 0
  pPocket = []
  if not (gActionLog = []) then
    howMany = count(gActionLog)
    repeat with n = 1 to howMany
      add(pPocket, getAt(gActionLog, n))
    end repeat
  end if
  if not (gItemLog = []) then
    howMany = count(gItemLog)
    repeat with n = 1 to howMany
      add(pPocket, getAt(gItemLog, n))
    end repeat
  end if
  curPlayerMember = "player.normal"
  lastHorizontalDirection = "right"
  frameOfAnimation = 1
  startPosition(me)
end

on startPosition me
  sprite(pSprite).loc = point(gPlayerStartLoc[1] * 16, gPlayerStartLoc[2] * 16)
  sprite(pSprite).ink = 36
end

on exitFrame me
  checkTheme(gSoundManager)
  if showingMessage then
    sfx_play1stop(gSoundManager)
    if keyPressed(RETURN) then
      showingMessage = 0
      repeat with n = gSprite[#SIGNBKG] to gSprite[#TALKTEXT]
        sprite(n).locV = 600
      end repeat
      if itemReceived then
        itemReceived = 0
        sendSprite(gInventorySprite, #openInventory)
      else
        sendSprite(gInventorySprite, #dontOpenInventory)
        resetStatus(me)
      end if
      updateStage()
    end if
  else
    if pStatus = #move then
      move(me, keyPressed(123) * -1 + keyPressed(124), keyPressed(126) * -1 + keyPressed(125))
    end if
  end if
end

on move me, dx, dy
  if dx = 0 and dy = 0 then
    sfx_play1stop(gSoundManager)
    exit
  end if
  loc = sprite(pSprite).loc
  rect = sprite(160).rect
  loc = loc + point(dx, dy) * pSpeed
  rect = rect + rect(dx * pSpeed, dy * pSpeed, dx * pSpeed, dy * pSpeed)
  scroll = #STAY
  if rect.left < -2 then
    scroll = #left
  else
    if rect.top < -2 then
      scroll = #top
    else
      if rect.right > 418 then
        scroll = #right
      else
        if rect.bottom > pBottom then
          scroll = #bottom
        end if
      end if
    end if
  end if
  if not (scroll = #STAY) then
    if gSpriteSet = #bottom then
      tempSet = #top
    end if
    if gSpriteSet = #top then
      tempSet = #bottom
    end if
  end if
  case scroll of
    #left:
      if gCurrentW = 1 then
        exit
      end if
      if not (gRoomsCopy[gCurrentW - 1][gCurrentH] = #empty) then
        scrollToLeft(me, tempSet)
      end if
      exit
    #right:
      if gCurrentW = gMapW then
        exit
      end if
      if not (gRoomsCopy[gCurrentW + 1][gCurrentH] = #empty) then
        scrollToRight(me, tempSet)
      end if
      exit
    #top:
      if gCurrentH = 1 then
        exit
      end if
      if not (gRoomsCopy[gCurrentW][gCurrentH - 1] = #empty) then
        scrollToTop(me, tempSet)
      end if
      exit
    #bottom:
      if gCurrentH = gMapH then
        exit
      end if
      if not (gRoomsCopy[gCurrentW][gCurrentH + 1] = #empty) then
        scrollToBottom(me, tempSet)
      end if
      exit
  end case
  tRect = rect + rect(2, 2, -2, -2)
  repeat with i = gLastSprite down to gFirstSprite
    sendSprite(i, #detectCollision, tRect, dx, dy)
    myData = the result
    if not (myData = 0) then
      who = myData[1]
      myMessage = myData[2]
      myValueCon = myData[3]
      exit repeat
    end if
  end repeat
  if not (myData = 0) then
    if not voidp(myMessage) then
      myMCopy = EMPTY
      repeat with x = 1 to myMessage.count
        mText = myMessage[x][#text]
        plrObj = myMessage[x][#plrObj]
        plrAct = myMessage[x][#plrAct]
        if plrObj = EMPTY and plrAct = EMPTY then
          myMCopy = mText
          next repeat
        end if
        if plrObj = EMPTY and not (plrAct = EMPTY) then
          if getOne(pPocket, plrAct) > 0 then
            myMCopy = myMessage[x][#text]
            exit repeat
          end if
          next repeat
        end if
        if not (plrObj = EMPTY) and plrAct = EMPTY then
          if getOne(pPocket, plrObj) > 0 then
            myMCopy = myMessage[x][#text]
            exit repeat
          end if
          next repeat
        end if
        if not (plrObj = EMPTY) and not (plrAct = EMPTY) then
          if getOne(pPocket, plrObj) > 0 and getOne(pPocket, plrAct) > 0 then
            myMCopy = myMessage[x][#text]
            exit repeat
          end if
        end if
      end repeat
      if not (myMCopy = EMPTY) then
        showMessage(me, i, who, myMCopy)
      end if
    end if
    if not voidp(myValueCon) then
      getItem = #no
      repeat with x = 1 to myValueCon.count
        if myValueCon[x] = #none then
          next repeat
        end if
        hasObj = myValueCon[x][#hasObj]
        hasAct = myValueCon[x][#hasAct]
        giveObj = myValueCon[x][#giveObj]
        giveAct = myValueCon[x][#giveAct]
        if hasObj = EMPTY and hasAct = EMPTY then
          getItem = #yes
          next repeat
        end if
        if hasObj = EMPTY and not (hasAct = EMPTY) then
          if getOne(pPocket, hasAct) > 0 then
            getItem = #yes
          end if
          exit repeat
          next repeat
        end if
        if not (hasObj = EMPTY) and hasAct = EMPTY then
          if getOne(pPocket, hasObj) > 0 then
            getItem = #yes
            deleteAt(pPocket, getPos(pPocket, hasObj))
            deleteAt(gItemLog, getPos(gItemLog, hasObj))
          end if
          exit repeat
          next repeat
        end if
        if not (hasObj = EMPTY) and not (hasAct = EMPTY) then
          if getOne(pPocket, hasObj) > 0 and getOne(pPocket, hasAct) > 0 then
            getItem = #yes
            deleteAt(pPocket, getOne(pPocket, hasObj))
          end if
          exit repeat
        end if
      end repeat
      if getItem = #yes then
        if not (giveObj = EMPTY) and getOne(pPocket, giveObj) = 0 and getOne(pPocket, "got" & giveObj) = 0 then
          add(pPocket, giveObj)
          if not getPos(gItemLog, giveObj) then
            add(gItemLog, giveObj)
            the itemDelimiter = RETURN
            howMany = the number of items in field "banned.list"
            repeat with n = 1 to howMany
              theObject = item n of field "banned.list"
              if giveObj = theObject then
                isBanned = 1
                exit repeat
              end if
            end repeat
            if not isBanned then
              itemReceived = 1
            end if
          end if
        end if
        if not (giveAct = EMPTY) and getOne(pPocket, giveAct) = 0 then
          add(pPocket, giveAct)
          if not getPos(gItemLog, giveAct) then
            add(gActionLog, giveAct)
          end if
        end if
      end if
    end if
  end if
  case who of
    #FLOR:
    #WALL:
      case sprite(i).pMove[#COND] of
        #push:
          sendSprite(i, #move, dx, dy)
          if gPushStatus = #stop then
            exit
          end if
          updateStage()
          sfx_play2(gSoundManager, #push)
        otherwise:
          sfx_play2(gSoundManager, #bump)
          sfx_play1stop(gSoundManager)
          exit
      end case
    #char:
      case sprite(i).pMove[#COND] of
        #push:
          sendSprite(i, #move, dx, dy)
          if gPushStatus = #stop then
            exit
          end if
          updateStage()
        otherwise:
          sfx_play1stop(gSoundManager)
          exit
      end case
    #WATER:
      if getOne(pPocket, "scuba") = 0 then
        showMessage(me, i, who, "You can't just walk into water!!!")
        sfx_play1stop(gSoundManager)
        exit
      else
        inWater = 1
      end if
    #item:
      where = sprite(i).pPointer
      myData = gRoomsCopy[gCurrentW][gCurrentH]
      sprite(i).locV = -50
      sprite(i).member = member("blank")
      updateStage()
      deleteAt(gRooms[gCurrentW][gCurrentH], where)
      sendSprite(i, #clearID)
    #DOOR:
      doDoor(me, i)
      exit
  end case
  if inWater then
    curPlayerMember = "player.boat"
    sfx_play1(gSoundManager, #boat)
  else
    curPlayerMember = "player.normal"
    sfx_play1(gSoundManager, #walk)
  end if
  sprite(pSprite).loc = loc
  frameOfAnimation = frameOfAnimation + 1
  if frameOfAnimation > 2 then
    frameOfAnimation = 1
  end if
  case 1 of
    dx > 0:
      characterDirection = "right"
    dx < 0:
      characterDirection = "left"
    otherwise:
      characterDirection = lastHorizontalDirection
  end case
  if curPlayerMember = "player.normal" then
    lastHorizontalDirection = characterDirection
  end if
  case 1 of
    dy > 0:
      characterDirection = "down"
    dy < 0:
      characterDirection = "up"
  end case
  sprite(pSprite).member = giveMember(me)
  pLastMove = the ticks
end

on giveMember me
  if curPlayerMember = "player.normal" then
    theMember = member(curPlayerMember & "." & lastHorizontalDirection & "." & frameOfAnimation)
  else
    theMember = member(curPlayerMember & "." & characterDirection)
  end if
  return theMember
end

on reportID me
  addProp(gSprite, #player, me.spriteNum)
end

on scrollToLeft me, tempSet
  updateItemLoc()
  gCurrentW = gCurrentW - 1
  myMargin = point(-(the stage).rect.width, 0)
  mySpeed = point(16, 0)
  playerLoc = point((the stage).rect.width, 0)
  newMap(me, tempSet, myMargin)
  scroll(me, #moveH, mySpeed, playerLoc)
end

on scrollToRight me, tempSet
  updateItemLoc()
  gCurrentW = gCurrentW + 1
  myMargin = point((the stage).rect.width, 0)
  mySpeed = point(-16, 0)
  playerLoc = point(-(the stage).rect.width, 0)
  newMap(me, tempSet, myMargin)
  scroll(me, #moveH, mySpeed, playerLoc)
end

on scrollToTop me, tempSet
  updateItemLoc()
  gCurrentH = gCurrentH - 1
  myMargin = point(0, -pBottom)
  mySpeed = point(0, 16)
  playerLoc = point(0, pBottom)
  newMap(me, tempSet, myMargin)
  scroll(me, #moveV, mySpeed, playerLoc)
end

on scrollToBottom me, tempSet
  updateItemLoc()
  gCurrentH = gCurrentH + 1
  myMargin = point(0, pBottom)
  mySpeed = point(0, -16)
  playerLoc = point(0, -pBottom)
  newMap(me, tempSet, myMargin)
  scroll(me, #moveV, mySpeed, playerLoc)
end

on newMap me, tempSet, myMargin
  gSpriteSet = tempSet
  checkSpriteSet()
  clearNewMap()
  updateMap(myMargin)
end

on scroll me, myDir, mySpeed, playerLoc
  sfx_play1stop(gSoundManager)
  scrollspeed = 20
  case myDir of
    #moveH:
      repeat with loop = 1 to 26
        m = the milliSeconds
        sprite(gSprite[#player]).loc = sprite(gSprite[#player]).loc + mySpeed
        if mySpeed < 0 and sprite(gSprite[#player]).locH < 16 then
          sprite(gSprite[#player]).locH = 16
        end if
        if mySpeed > 0 and sprite(gSprite[#player]).locH > 400 then
          sprite(gSprite[#player]).locH = 400
        end if
        repeat with sNum = 10 to 149
          if sprite(sNum).member.name = "blank" then
            next repeat
          end if
          sprite(sNum).loc = sprite(sNum).loc + mySpeed
        end repeat
        updateStage()
        repeat while the milliSeconds - m < scrollspeed
        end repeat
      end repeat
    #moveV:
      repeat with loop = 1 to 20
        m = the milliSeconds
        sprite(gSprite[#player]).loc = sprite(gSprite[#player]).loc + mySpeed
        if mySpeed < 0 and sprite(gSprite[#player]).locV < 16 then
          sprite(gSprite[#player]).locV = 16
        end if
        if mySpeed > 0 and sprite(gSprite[#player]).locV > 303 then
          sprite(gSprite[#player]).locV = 303
        end if
        repeat with sNum = 10 to 149
          if sprite(sNum).member.name = "blank" then
            next repeat
          end if
          sprite(sNum).loc = sprite(sNum).loc + mySpeed
        end repeat
        updateStage()
        repeat while the milliSeconds - m < scrollspeed
        end repeat
      end repeat
      if mySpeed[2] > 0 then
        myShift = -1
      end if
      if mySpeed[2] < 0 then
        myShift = 1
      end if
      repeat with sNum = 10 to 149
        sprite(sNum).locV = sprite(sNum).locV + myShift
      end repeat
  end case
end

on detectCollision me, rect
  if intersect(rect, sprite(pSprite).rect) <> rect(0, 0, 0, 0) then
    return 1
  else
    return 0
  end if
end

on showMessage me, mySprite, who, myMessage
  if not showingMessage then
    showingMessage = 1
    myText = myMessage
    case who of
      #char:
        pStatus = #TALK
        showTalk(me, mySprite, myText)
        exit
      #item:
        pStatus = #TALK
        showTalk(me, mySprite, myText)
        exit
      otherwise:
        pStatus = #READ
        showSign(me, mySprite, myText)
        exit
    end case
  end if
end

on showSign me, mySprite, myText
  sfx_play3(gSoundManager, #show)
  sprite(gSprite[#SIGNBKG]).loc = point(208, 160)
  sprite(gSprite[#SIGNTEXT]).loc = point(87, 90)
  sprite(gSprite[#SIGNBKG]).member = member("sign.bkg")
  member("sign.text").scrollTop = 1
  member("sign.text").text = myText
  updateStage()
end

on showTalk me, mySprite, myText
  sfx_play3(gSoundManager, #show)
  if not voidp(myText) then
    sprite(gSprite[#TALKBKG]).loc = point(208, 160)
    sprite(gSprite[#TALKFACE]).loc = point(122, 120)
    sprite(gSprite[#TALKBKG]).member = member("talk.bkg")
    sprite(gSprite[#TALKFACE]).member = sprite(mySprite).member.name & ".face"
    sprite(gSprite[#TALKTEXT]).loc = point(175, 74)
    member("talk.text").scrollTop = 1
    member("talk.text").text = myText
    updateStage()
  else
    resetStatus(me)
  end if
end

on doDoor me, mySprite
  the itemDelimiter = "="
  myName = sprite(mySprite).pItem[#name]
  myAction = myName.item[1]
  case myAction of
    "FRAME":
      sfx_play2(gSoundManager, #DOOR)
      sfx_play1stop(gSoundManager)
      stopTheme(gSoundManager)
      maxVolumes(gSoundManager)
      toWhere = myName.item[2]
      go(toWhere)
      exit
    "ROOM":
      the itemDelimiter = "."
      tempRoomW = myName.item[1]
      roomH = integer(myName.item[2])
      posX = integer(myName.item[3])
      posY = integer(myName.item[4])
      the itemDelimiter = "="
      roomW = integer(tempRoomW.item[2])
      if voidp(roomW) or voidp(roomH) then
        exit
      end if
      if roomW > gRoomsCopy.count or roomH > gRoomsCopy[1].count then
        exit
      end if
      sfx_play2(gSoundManager, #DOOR)
      gCurrentW = roomW
      gCurrentH = roomH
      gPlayerStartLoc = [posX, posY]
      go("reenter")
      exit
  end case
end

on resetStatus me
  pStatus = #move
end

on checkForMessage me
  return showingMessage
end

on disableMovement me
  pStatus = #stop
  sfx_play1stop(gSoundManager)
end
