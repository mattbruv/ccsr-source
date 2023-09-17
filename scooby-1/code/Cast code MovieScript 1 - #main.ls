global gRooms, gRoomsCopy, gCurrentW, gCurrentH, gMapW, gMapH, gSpriteSet, gFirstSprite, gLastSprite, gSprite, gMainPath, gPathDiv, gConMove, gSoundManager, curPlayerMember, gPlayerStartLoc, lastCharacterDirection, frameOfAnimation, gActionLog, gItemLog, gameStage, gFlashSeq, gFlashSecs

on prepareMovie
  if isShocked() then
    tellStreamStatus(1)
  end if
end

on startMovie
  the actorList = []
  clearGlobals()
  if the soundDevice <> "DirectSound" then
    the soundDevice = "DirectSound"
  end if
  if the soundDevice <> "DirectSound" then
    the soundDevice = "QT3Mix"
  end if
end

on changeGameStage newStage
  gameStage = newStage
end

on streamStatus url, state, bytesSoFar, bytesTotal, error
  if float(bytesSoFar) = float(bytesTotal) then
    tellStreamStatus(0)
    showInstructions()
  else
    percentDone = integer(float(bytesSoFar) / float(bytesTotal) * 100)
    percentText = percentDone & "%"
    member("percentageLoaded").text = percentText
  end if
end

on showInstructions
  puppetTempo(12)
  set the volume of sound 1 to 255
  puppetSound(1, "pipe.organ")
  changeGameStage(#BEGINNING)
  go("instruct")
end

on startGame
  resetVars()
  useFinalData()
  turnedOff = 1
  changeCursor("nothing")
  changeGameStage(#MIDDLE)
  go("game")
end

on resetVars
  gSoundManager = new(script("sound_manager"))
  gPlayerStartLoc = [11, 16]
  gRooms = []
  gRoomsCopy = []
  gSprite = [:]
  gMapW = 4
  gMapH = 4
  gCurrentW = 2
  gCurrentH = 1
  gItemLog = []
  gActionLog = []
  gFlashSeq = 0
  gFlashSecs = the milliSeconds
  curPlayerMember = "player.normal"
  lastCharacterDirection = "right"
  frameOfAnimation = 1
  gSpriteSet = #bottom
  gConMove = [#none, #AUTO, #push, #pull, #movex, #movey]
  checkSpriteSet()
end

on checkSpriteSet
  case gSpriteSet of
    #bottom:
      gFirstSprite = 10
      gLastSprite = 79
    #top:
      gFirstSprite = 80
      gLastSprite = 149
  end case
end

on dataReady
  gRooms = value(member("map.data.txt").text)
  gMapW = gRooms.count
  gMapH = gRooms[1].count
  gRoomsCopy = duplicate(gRooms)
end

on enterNewRoom
  if not (gRoomsCopy[gCurrentW][gCurrentH] = #empty) then
    myMargin = point(0, 0)
    updateMap(myMargin)
  else
    clearMap()
  end if
end

on updateMap myMargin
  clearMap()
  gRoomsCopy = duplicate(gRooms)
  myData = gRoomsCopy[gCurrentW][gCurrentH]
  repeat with sNum = gFirstSprite to gFirstSprite + myData.count - 1
    myNum = sNum - gFirstSprite + 2
    if myNum > myData.count then
      exit repeat
    end if
    sprite(sNum).visible = 1
    sprite(sNum).member = myData[myNum][#member]
    x = (myData[myNum][#location][1] * 16) + myData[myNum][#WSHIFT]
    y = (myData[myNum][#location][2] * 16) + myData[myNum][#HSHIFT]
    sprite(sNum).loc = point(x, y) + myMargin
    sprite(sNum).width = myData[myNum][#width]
    sprite(sNum).height = myData[myNum][#height]
    sprite(sNum).pType = myData[myNum][#data][#item][#type]
    sprite(sNum).ink = 36
    myPointer = myNum
    sendSprite(sNum, #getData, myData[myNum][#data], myData[myNum][#location], myPointer)
  end repeat
  updateStage()
end

on updateItemLoc
  myData = gRoomsCopy[gCurrentW][gCurrentH]
  repeat with sNum = gFirstSprite to gFirstSprite + myData.count - 1
    myNum = sNum - gFirstSprite + 2
    if myNum > myData.count then
      exit repeat
    end if
    myData[myNum][#location][1] = sprite(sNum).locH / 16
    myData[myNum][#location][2] = sprite(sNum).locV / 16
  end repeat
  updateStage()
end

on clearNewMap
  if gSpriteSet = #bottom then
    repeat with n = 80 to 149
      sendSprite(n, #clearID)
    end repeat
  else
    repeat with n = 10 to 79
      sendSprite(n, #clearID)
    end repeat
  end if
end

on clearMap
  repeat with sNum = gFirstSprite to gLastSprite
    sprite(sNum).member = "blank"
    sprite(sNum).locV = -5000
    sendSprite(sNum, #resetData)
    sendSprite(sNum, #resetRect)
  end repeat
  updateStage()
end

on CuePassed whichChannel, cuePointNumber, cuePointName
  someCuePassed(gSoundManager, cuePointName)
end

on exitArea
  gPlayerStartLoc = [11, 10]
  startTheme(gSoundManager)
end

on useFinalData
  gStatus = #DATA_READY
  myW = 4
  myH = 4
  gRooms = []
  repeat with w = 1 to myW
    tempList = []
    repeat with h = 1 to myH
      nameH = string(h)
      nameH = string(h)
      if w < 10 then
        nameW = "0" & string(w)
      end if
      if h < 10 then
        nameH = "0" & string(h)
      end if
      myName = nameW & nameH
      myFile = member(myName).text
      if myFile = "empty" then
        myList = #empty
      else
        myList = value(myFile)
      end if
      add(tempList, myList)
    end repeat
    add(gRooms, tempList)
  end repeat
  gMapW = gRooms.count
  gMapH = gRooms[1].count
  gRoomsCopy = duplicate(gRooms)
  startTheme(gSoundManager)
end

on changeCursor theCursor
  case 1 of
    (theCursor = "arrow"):
      cursor(-1)
    (theCursor = "finger"):
      cursor(280)
    (theCursor = "nothing"):
      cursor(200)
  end case
end
