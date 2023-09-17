global gFlashSeq, gFlashSecs

on prepareFlash
  gFlashSeq = 1
  setStatic(1, 0)
  changeCursor("nothing")
end

on checkFlashState
  if flashIsStopped(1) then
    if not soundBusy(1) then
      thisList = [4000, 2500, 2000, 2500, 2000]
      thisIndex = gFlashSeq + 1
      theseSecs = thisList[thisIndex]
      if timeElapsed(gFlashSecs, theseSecs) then
        gFlashSeq = gFlashSeq + 1
        if gFlashSeq = 2 then
          playSound("howl", 1)
        else
          if gFlashSeq = 4 then
            playSound("ghost_02", 1)
          else
            if gFlashSeq >= 5 then
              goToFlashFrame(1, "ending")
              go("lastScreen")
              exit
            end if
          end if
        end if
        thisFrame = "seq" & gFlashSeq
        playflashFrame(1, thisFrame)
        gFlashSecs = the milliSeconds
      end if
    end if
  else
    gFlashSecs = the milliSeconds
  end if
end

on clickOnFlash
  if soundBusy(1) then
    exit
  end if
  if not flashIsStopped(1) then
    exit
  end if
  gFlashSeq = gFlashSeq + 1
  if gFlashSeq >= 5 then
    goToFlashFrame(1, "ending")
    go("lastScreen")
  else
    if gFlashSeq = 2 then
      playSound("howl", 1)
    else
      if gFlashSeq = 4 then
        playSound("ghost_02", 1)
      end if
    end if
    thisFrame = "seq" & gFlashSeq
    playflashFrame(1, thisFrame)
  end if
end

on playAgain me
  startGame()
end
