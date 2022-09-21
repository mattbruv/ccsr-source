property pSprite, pWho, pData, pLoc, pMove, pDir, pDirList, pSpeed, pBottom, pStatus, pMember, pMargin, pCheckVisi, pRect, pType, pMessage, pItem, pPointer
global gSprite, gFirstSprite, gLastSprite, gPushStatus, gConMove, gSoundManager, gRoomsCopy, gCurrentW, gCurrentH

on beginSprite me
  pSprite = me.spriteNum
  pSpeed = 4
  pBottom = 320
  pStatus = #normal
  pMember = sprite(pSprite).member.name
  pRect = sprite(pSprite).rect
  pData = [:]
  pMessage = []
end

on resetData me
  pData = [:]
end

on resetRect me
  sprite(pSprite).rect = pRect
end

on getData me, myData, myLoc, myPointer
  pCheckVisi = #WAIT
  pPointer = myPointer
  pData = myData
  pLoc = myLoc
  if not (myData = [:]) then
    processData(me, myData, myLoc)
  end if
  checkVisible(me)
  pCheckVisi = #done
end

on processData me, myData, myLoc
  myItem = myData[#item]
  pItem = [:]
  pItem[#name] = myItem[#name]
  pItem[#visi] = myItem[#visi]
  pItem[#COND] = myItem[#COND]
  myMove = myData[#move]
  pMove = [:]
  pDirList = []
  pMove[#timer] = [myMove[#TIMEA], myMove[#TIMEB]]
  pMove[#COND] = gConMove[myMove[#COND]]
  case pMove[#COND] of
    #push:
      pMove[#T] = 1
      pMove[#b] = 20
      pMove[#L] = 1
      pMove[#R] = 26
      pSpeed = sprite(gSprite[#player]).pSpeed
    #AUTO:
      pMove[#T] = myLoc[2] - myMove[1]
      pMove[#b] = myLoc[2] + myMove[2]
      pMove[#L] = myLoc[1] - myMove[3]
      pMove[#R] = myLoc[1] + myMove[4]
      if not (myMove[1] = 0) then
        add(pDirList, #UP)
      end if
      if not (myMove[3] = 0) then
        add(pDirList, #left)
      end if
      if not (myMove[2] = 0) then
        add(pDirList, #down)
      end if
      if not (myMove[4] = 0) then
        add(pDirList, #right)
      end if
      if pDirList.count = 0 then
        pMove[#COND] = 1
      end if
  end case
end

on clearID me
  pWho = VOID
  pData = VOID
end

on exitFrame me
  if sprite(pSprite).member.name = "blank" then
    exit
  end if
  if voidp(pMove) then
    exit
  end if
  if not (sprite(gSprite[#player]).pStatus = #move) then
    exit
  end if
  if not (pMove[#COND] = #none) then
    doMove(me)
  end if
  checkVisible(me)
  doNameCheck(me)
end

on checkVisible me
  if voidp(pData) then
    exit
  end if
  temp = pData[#item][#visi]
  visiObj = temp[#visiObj]
  visiAct = temp[#visiAct]
  inviObj = temp[#inviObj]
  inviAct = temp[#inviAct]
  tPocket = sprite(gSprite[#player]).pPocket
  if visiObj = EMPTY and visiAct = EMPTY and inviObj = EMPTY and inviAct = EMPTY then
    visiStat = #show
  else
    if not (visiObj = EMPTY) or not (visiAct = EMPTY) then
      if getOne(tPocket, visiObj) > 0 or getOne(tPocket, visiAct) > 0 then
        visiStat = #show
        secret = 1
      else
        visiStat = #hide
      end if
    else
      if getOne(tPocket, inviObj) > 0 or getOne(tPocket, inviAct) > 0 then
        visiStat = #hide
      else
        visiStat = #show
      end if
    end if
  end if
  if secret and not (sprite(pSprite).locV > 0) then
    sfx_play3(gSoundManager, #secret)
  end if
  if visiStat = #hide then
    sprite(pSprite).locV = -5000
  else
    if pCheckVisi = #done and sprite(pSprite).locV < 0 then
      myData = gRoomsCopy[gCurrentW][gCurrentH]
      x = pLoc[1] * 16 + myData[pPointer][#WSHIFT]
      y = pLoc[2] * 16 + myData[pPointer][#HSHIFT]
      sprite(pSprite).loc = point(x, y)
    end if
  end if
end

on doNameCheck me
  if voidp(pData) then
    exit
  end if
  myName = pData[#item][#name]
  if myName = EMPTY then
    exit
  end if
  mPlayer = gSprite[#player]
  if getOne(sprite(mPlayer).pPocket, myName) > 0 then
    exit
  end if
  myRect = sprite(pSprite).rect
  repeat with i = gLastSprite down to gFirstSprite
    if i = pSprite or sprite(i).locV < 0 then
      next repeat
    end if
    if sprite(i).member.name = "blank" then
      next repeat
    end if
    spName = sprite(i).pData[#item][#name]
    if not (spName = EMPTY) and spName = myName then
      case sprite(i).member.type of
        #shape:
          x = sprite(i).left + sprite(i).width / 2
          y = sprite(i).top + sprite(i).height / 2
          myLoc = point(x, y)
          if myLoc = sprite(pSprite).loc and getOne(sprite(mPlayer).pPocket, "got" & myName) = 0 then
            add(sprite(mPlayer).pPocket, myName)
            add(sprite(mPlayer).pPocket, "got" & myName)
            exit
          end if
        #bitmap:
          if sprite(i).loc = sprite(pSprite).loc and getOne(sprite(mPlayer).pPocket, "got" & myName) = 0 then
            add(sprite(mPlayer).pPocket, myName)
            add(sprite(mPlayer).pPocket, "got" & myName)
            exit
          end if
      end case
      objLoc = sprite(i).loc
      if inside(objLoc, myRect) and getOne(sprite(mPlayer).pPocket, "got" & myName) = 0 then
        add(sprite(mPlayer).pPocket, myName)
        add(sprite(mPlayer).pPocket, "got" & myName)
      end if
    end if
  end repeat
end

on doMove me
  if pStatus = #normal then
    case pMove[#COND] of
      #push:
      #AUTO:
        moveAuto(me)
    end case
  end if
end

on moveAuto me
  if voidp(pDir) then
    pDir = pDirList[random(pDirList.count)]
  end if
  case pDir of
    #UP:
      move(me, 0, -1)
    #down:
      move(me, 0, 1)
    #left:
      move(me, -1, 0)
    #right:
      move(me, 1, 0)
  end case
end

on move me, dx, dy
  if dx = 0 and dy = 0 then
    exit
  end if
  loc = sprite(pSprite).loc
  w = sprite(pSprite).width
  h = sprite(pSprite).height
  rect = sprite(pSprite).rect
  loc = loc + point(dx, dy) * pSpeed
  rect = rect + rect(dx * pSpeed, dy * pSpeed, dx * pSpeed, dy * pSpeed)
  if rect.left < pMove[#L] * 16 - w / 2 or rect.left < 0 then
    pickNewDirection(me)
    exit
  else
    if rect.top < pMove[#T] * 16 - h / 2 or rect.top < 0 then
      pickNewDirection(me)
      exit
    else
      if rect.right > pMove[#R] * 16 + w / 2 or rect.right > (the stage).rect.width then
        pickNewDirection(me)
        exit
      else
        if rect.bottom > pMove[#b] * 16 + h / 2 or rect.bottom > pBottom then
          pickNewDirection(me)
          exit
        end if
      end if
    end if
  end if
  tRect = rect
  if pType = #char then
    tRect = rect + rect(2, 2, -2, -2)
  end if
  repeat with i = gLastSprite down to gFirstSprite
    if i = pSprite then
      next repeat
    end if
    sendSprite(i, #detectCollision, tRect, dx, dy)
    myData = the result
    if myData = 0 then
      gPushStatus = #move
      next repeat
    end if
    who = myData[1]
    case who of
      #WALL:
        gPushStatus = #stop
        pickNewDirection(me)
        exit
      #char:
        gPushStatus = #stop
        pickNewDirection(me)
        exit
      #FLOR:
      otherwise:
        gPushStatus = #move
    end case
  end repeat
  sendSprite(gSprite[#player], #detectCollision, rect, dx, dy)
  if the result = 1 then
    pickNewDirection(me)
    exit
  end if
  if who = #WALL then
    exit
  end if
  sprite(pSprite).loc = loc
  pLastMove = the ticks
  if random(20) = 1 then
    pickNewDirection(me, who)
  end if
end

on pickNewDirection me
  gPushStatus = #stop
  if not (pMove[#COND] = #AUTO) then
    exit
  end if
  temp = duplicate(pDirList)
  oldDir = getPos(temp, pDir)
  newDir = oldDir + 1
  if newDir > temp.count then
    newDir = 1
  end if
  pDir = temp[newDir]
end

on detectCollision me, rect
  if intersect(rect, sprite(pSprite).rect) <> rect(0, 0, 0, 0) then
    data = [pType, pData[#message], pItem[#COND]]
    return data
  else
    return 0
  end if
end
