property pScoobyOffSetList, pShaggySprite, pLocList, pDirList, pCurrDir, pLastDir, pLastLoc, pMyState, pDelta
global gSprite, gLastSprite, gFirstSprite

on beginSprite me
  me.pMyState = 0
  me.pDelta = point(0, 0)
  me.pScoobyOffSetList = [#left: point(48, 17), #top: point(0, 60), #right: point(-48, 17), #bottom: point(0, -60), #pLeft: point(48, 17), #pTop: point(0, 0), #pRight: point(-48, 17), #pBottom: point(0, 0)]
  me.pShaggySprite = me.spriteNum + 1
  me.pLocList = []
  me.pDirList = []
  me.pCurrDir = "right"
  me.pLastDir = "right"
  me.pLastLoc = sprite(me.spriteNum).loc
end

on mSetMyState me, thisState
  me.pMyState = thisState
end

on mStartPosition me, thisLoc, thisInk, thisSpeed
  sprite(me.spriteNum).loc = thisLoc + me.mGetScoobyOffSet("right")
  sprite(me.spriteNum).ink = thisInk
end

on mMove me, thisLoc, thisDir, thisFrame, thisSpeed, thisRect
  if me.mIsPerpendicular(thisDir) then
    thisOffSet = me.mGetScoobyOffSet(thisDir, 1)
  else
    thisOffSet = me.mGetScoobyOffSet(thisDir, 0)
  end if
  if me.mCanMove(thisLoc, thisDir, thisOffSet, thisRect) then
    thisDelta = me.mGetDelta(thisLoc, thisDir, thisOffSet)
    newLoc = sprite(me.spriteNum).loc + thisDelta
    updateStage()
    thisRect = sprite(me.spriteNum).rect
    thisRect = offset(thisRect, thisDelta[1], thisDelta[2])
    me.pDelta = thisDelta
    newDir = me.mGetDir(thisDelta)
    if newDir <> -1 then
      sprite(me.spriteNum).member = me.mGetScoobyMember(newDir, thisFrame)
      sprite(me.spriteNum).loc = sprite(me.spriteNum).loc + thisDelta
      if newDir = "up" then
        sprite(me.spriteNum).locZ = me.spriteNum + 2
      else
        sprite(me.spriteNum).locZ = me.spriteNum
      end if
      me.pLastDir = newDir
      updateStage()
    end if
  else
    sprite(me.spriteNum).locZ = me.spriteNum
    me.pDelta = thisSpeed
  end if
end

on mCheckCollisions me, thisRect, thisDelta
  repeat with i = gLastSprite down to gFirstSprite
    thisType = sendSprite(i, #mGetPType)
    if thisType <> #WALL then
      next repeat
    end if
    collisionRect = sendSprite(i, #mRectIntersects, thisRect)
    if collisionRect <> rect(0, 0, 0, 0) then
      sprite(162).rect = collisionRect
      updateStage()
      hCollide = collisionRect[3] - collisionRect[1]
      if hCollide <= 16 then
        if hCollide <> 0 then
          if thisDelta[1] > 0 then
            thisDelta[1] = thisDelta[1] - hCollide - 1
          else
            thisDelta[1] = thisDelta[1] + hCollide + 1
          end if
        end if
      end if
      vCollide = collisionRect[4] - collisionRect[2]
      if vCollide <= 16 then
        if vCollide <> 0 then
          if thisDelta[2] > 0 then
            thisDelta[2] = thisDelta[2] - vCollide - 1
          else
            thisDelta[2] = thisDelta[2] + vCollide + 1
          end if
        end if
      end if
      exit repeat
    end if
  end repeat
  return thisDelta
end

on mGetDelta me, shaggyLoc, thisDir, thisOffSet
  thisDelta = point(0, 0)
  thisUnit = 8
  thisLoc = thisOffSet + shaggyLoc
  myLoc = sprite(me.spriteNum).loc
  if myLoc[1] < thisLoc[1] then
    thisDelta[1] = thisDelta[1] + thisUnit
  else
    if myLoc[1] > thisLoc[1] then
      thisDelta[1] = thisDelta[1] - thisUnit
    else
      thisDelta[1] = 0
    end if
  end if
  if myLoc[2] > thisLoc[2] then
    thisDelta[2] = thisDelta[2] - thisUnit
  else
    if myLoc[2] < thisLoc[2] then
      thisDelta[2] = thisDelta[2] + thisUnit
    else
      thisDelta[2] = 0
    end if
  end if
  return thisDelta
end

on mDoMove me, thisLoc, thisOffSet, thisDir, thisFrame
  newLoc = thisLoc + thisOffSet
  newDir = thisDir
  sprite(me.spriteNum).member = me.mGetScoobyMember(newDir, thisFrame)
  sprite(me.spriteNum).loc = newLoc
  deleteAt(me.pLocList, 1)
  deleteAt(me.pDirList, 1)
end

on mAutoMove me, thisFrame, thisDir, thisLoc
  if thisDir <> me.pCurrDir then
    me.pLastLoc = thisLoc
    me.pLastDir = me.pCurrDir
    me.pCurrDir = thisDir
  end if
  sprite(me.spriteNum).member = me.mGetScoobyMember(me.pLastDir, thisFrame)
  newLoc = sprite(me.spriteNum).loc + me.pDelta
  if me.mLocReached(newLoc, me.pLastLoc, me.pLastDir) then
    newLoc = me.pLastLoc
    me.pCurrDir = thisDir
    me.pDelta = point(0, 0)
    me.mSetMyState(0)
  end if
  sprite(me.spriteNum).loc = newLoc
end

on mLocReached me, newLoc, destLoc, thisDir
  case thisDir of
    "left":
      if newLoc[1] <= destLoc[1] then
        return 1
      end if
      return 0
    "right":
      if newLoc[1] >= destLoc[1] then
        return 1
      end if
      return 0
    "up":
      if newLoc[2] <= destLoc[2] then
        return 1
      end if
      return 0
    "down":
      if newLoc[2] >= destLoc[2] then
        return 1
      end if
      return 0
    otherwise:
      return 0
  end case
end

on mGetScoobyMember me, thisDir, thisFrame
  return member("scooby." & thisDir & "." & thisFrame)
end

on mGetScoobyOffSet me, thisDir, isPerpendicular
  if not isPerpendicular then
    if thisDir = "left" then
      thisIndex = 1
    else
      if thisDir = "up" then
        thisIndex = 2
      else
        if thisDir = "right" then
          thisIndex = 3
        else
          thisIndex = 4
        end if
      end if
    end if
  else
    if thisDir = "left" then
      thisIndex = 5
    else
      if thisDir = "up" then
        thisIndex = 6
      else
        if thisDir = "right" then
          thisIndex = 7
        else
          thisIndex = 8
        end if
      end if
    end if
  end if
  return me.pScoobyOffSetList[thisIndex]
end

on mScroll me, thisSpeed
  me.mClearLists()
  sprite(me.spriteNum).loc = sprite(me.spriteNum).loc + thisSpeed
end

on mClearLists me
  me.pLocList = []
  me.pDirList = []
end

on mCanMove me, thisLoc, thisDir, thisOffSet, thisRect
  myRect = sprite(me.spriteNum).rect
  if intersect(myRect, thisRect) <> rect(0, 0, 0, 0) then
    return 0
  end if
  return 1
end

on mIsPerpendicular me, thisDir
  case me.pCurrDir of
    "up", "down":
      if thisDir = "left" then
        return 1
      end if
      if thisDir = "right" then
        return 1
      end if
      return 0
    "left", "right":
      if thisDir = "up" then
        return 1
      end if
      if thisDir = "down" then
        return 1
      end if
      return 0
    otherwise:
      return 0
  end case
end

on mGetDir me, thisDelta
  if thisDelta[2] > 0 then
    return "down"
  end if
  if thisDelta[2] < 0 then
    return "up"
  end if
  if thisDelta[1] > 0 then
    return "right"
  end if
  if thisDelta[1] < 0 then
    return "left"
  end if
  return -1
end

on mAdjustDelta me, thisLoc, newLoc, thisDir, thisOffSet, thisDelta
  case thisDir of
    "up":
      if thisLoc[2] <= (newLoc[2] - thisOffSet[2]) then
        return thisDelta
      else
        return point(thisDelta[1], thisLoc[2])
      end if
    "left":
      if thisLoc[1] <= (newLoc[1] - thisOffSet[1]) then
        return thisDelta
      else
        return point(thisOffSet[1], thisDelta[2])
      end if
    "right":
      if thisLoc[1] >= (newLoc[1] + abs(thisOffSet[1])) then
        return thisDelta
      else
        return point(thisOffSet[1], thisDelta[2])
      end if
    "down":
      if thisLoc[2] >= (newLoc[2] + abs(thisOffSet[2])) then
        return thisDelta
      else
        return point(thisDelta[1], thisOffSet[2])
      end if
    otherwise:
      return thisDelta
  end case
end
