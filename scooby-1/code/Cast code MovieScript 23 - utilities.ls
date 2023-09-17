on getSpriteLocs firstSprite, lastSprite
  thisList = []
  repeat with i = firstSprite to lastSprite
    add(thisList, sprite(i).loc)
  end repeat
  return thisList
end

on setRegPointMid thisMember
  thisWidth = member(thisMember).width
  thisHeight = member(thisMember).height
  member(thisMember).regPoint = point(thisWidth / 2, thisHeight / 2)
end

on playSound thisSound, thisChannel
  puppetSound(thisChannel, thisSound)
end

on stopAllSounds
  repeat with i = 1 to 4
    if soundBusy(i) then
      puppetSound(i, 0)
    end if
  end repeat
end

on setSoundVolume thisChannel, thisValue
  set the volume of sound thisChannel to thisValue
end

on muteAllSounds
  repeat with i = 1 to 8
    setSoundVolume(i, 0)
  end repeat
end

on restoreAllSounds
  repeat with i = 1 to 8
    setSoundVolume(i, 255)
  end repeat
end

on setRegPt firstMember, lastMember
  repeat with i = firstMember to lastMember
    setRegPointMid(i)
  end repeat
end

on replaceThisText thisMember, thisChar, newChar
  newText = EMPTY
  numLines = member(thisMember).line.count
  if numLines then
    repeat with i = 1 to numLines
      thisLine = member(thisMember).line[i]
      numChars = thisLine.char.count
      if numChars then
        repeat with j = 1 to numChars
          currentChar = thisLine.char[j]
          if currentChar <> QUOTE then
            put currentChar after newText
          end if
        end repeat
        put RETURN after newText
      end if
    end repeat
  end if
  newMember = new(#field)
  newMember.text = newText
  newMember.name = "AlteredQs"
end

on reverseThisList thisList
  newList = []
  numItems = thisList.count
  if numItems then
    repeat while numItems
      add(newList, thisList[numItems])
      numItems = numItems - 1
    end repeat
  end if
  return newList
end

on importAllCastLibs
  numLibs = the number of castLibs
  repeat with i = 1 to numLibs
    importThisCastLib(i)
  end repeat
  put "done"
end

on importThisCastLib thisCastLib
  numMembers = the number of castMembers of castLib thisCastLib
  if numMembers then
    repeat with i = 1 to numMembers
      thisMember = member(i, thisCastLib)
      if thisMember.type = #bitmap then
        importThisMember(thisMember)
      end if
    end repeat
  end if
end

on importThisMember thisMember
  thisName = thisMember.name
  thisFile = thisMember.fileName
  if thisFile <> EMPTY then
    importFileInto(thisMember, thisFile)
    thisMember.name = thisName
  end if
end

on setTheseRegPoints firstM, lastM, thisCastLib
  repeat with i = firstM to lastM
    thisMember = member(i, thisCastLib)
    setRegPointMid(thisMember)
  end repeat
  return "Done"
end

on isShocked
  return the runMode contains "Plugin"
end

on truncateThisList thisList, numItems
  if not listp(thisList) then
    exit
  end if
  listCount = thisList.count
  if listCount > numItems then
    repeat while listCount > numItems
      deleteAt(thisList, listCount)
      listCount = listCount - 1
    end repeat
  end if
end

on setFont thisMember, thisFont
  if ilk(thisMember) <> #member then
    thisMember = member(thisMember)
  end if
  thisMember.font = thisFont
end

on isFlash thisSprite
  if sprite(thisSprite).member.type = #flash then
    return 1
  end if
  return 0
end

on isFlashMember thisMember
  if member(thisMember).type <> #flash then
    return 0
  end if
  return 1
end

on playFlash thisSprite
  if isFlash(thisSprite) then
    play(sprite(thisSprite))
  end if
end

on stopFlash thisSprite
  if isFlash(thisSprite) then
    stop(sprite(thisSprite))
  end if
end

on playflashFrame thisSprite, thisFrame
  if not isFlash(thisSprite) then
    exit
  end if
  gotoFrame(sprite(thisSprite), thisFrame)
  play(sprite(thisSprite))
end

on goToFlashFrame thisSprite, thisFrame, thisQuality
  if not isFlash(thisSprite) then
    exit
  end if
  if not voidp(thisQuality) then
    sprite(thisSprite).quality = thisQuality
  end if
  gotoFrame(sprite(thisSprite), thisFrame)
end

on flashIsStopped thisSprite
  if isFlash(thisSprite) then
    if sprite(thisSprite).playing then
      return 0
    end if
    return 1
  else
    return 0
  end if
end

on setStatic thisSprite, thisState
  if isFlash(thisSprite) then
    sprite(thisSprite).static = thisState
  end if
end

on setStaticMember thisMember, thisState
  if isFlashMember(thisMember) then
    member(thisMember).static = thisState
  end if
end

on FindLastLabel
  repeat with i = 1 to the number of lines in the labelList
    if the frame < label(line i of the labelList) then
      return line i - 1 of the labelList
    end if
  end repeat
  return line the number of lines in the labelList - 1 of the labelList
end

on isSameSign valueA, valueB
  if (valueA >= 0) and (valueB >= 0) then
    return 1
  end if
  if (valueA < 0) and (valueB < 0) then
    return 1
  end if
  return 0
end

on dupeThisList thisList, numTimes
  newList = []
  thisCounter = 1
  repeat while thisCounter <= numTimes
    repeat with thisItem in thisList
      add(newList, thisItem)
    end repeat
    thisCounter = thisCounter + 1
  end repeat
  return newList
end

on timeElapsed theseSecs, thisDelay
  if (the milliSeconds - theseSecs) >= thisDelay then
    return 1
  end if
  return 0
end

on getRadian thisRotation
  return sin(thisRotation) * 0.017453
end
