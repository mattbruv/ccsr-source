global gFlashSeq, gFlashSecs

on prepareFlash
  gFlashSeq = 1
  setStatic(1, 0)
  changeCursor("nothing")
  gFlashSecs = the milliSeconds
end

on checkFlashState
  if flashIsStopped(1) then
    if not soundBusy(1) then
      thisList = [4000, 3000, 3000, 3500, 2000]
      thisIndex = gFlashSeq
      theseSecs = thisList[thisIndex]
      if timeElapsed(gFlashSecs, theseSecs) then
        gFlashSeq = gFlashSeq + 1
        if gFlashSeq = 4 then
          playSound("scooby dooby doo", 1)
        else
          if gFlashSeq >= 5 then
            goToFlashFrame(1, "ending")
            go("lastScreen")
            exit
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
  if gFlashSeq = 4 then
    exit
  end if
  gFlashSeq = gFlashSeq + 1
  if gFlashSeq >= 5 then
    goToFlashFrame(1, "ending")
    go("lastScreen")
  else
    thisFrame = "seq" & gFlashSeq
    playflashFrame(1, thisFrame)
    if gFlashSeq = 4 then
      playSound("scooby dooby doo", 1)
    end if
  end if
end

on playAgain me
  startGame()
end
