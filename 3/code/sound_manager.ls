property pSound1, pSound2, pSound3, numTimesMain, doTheme

on new me
  clearSounds(me)
  return me
end

on clearSounds me
  puppetSound(1, 0)
  puppetSound(2, 0)
  puppetSound(3, 0)
  puppetSound(4, 0)
end

on sfx_play1 me, what
  case what of
    #walk:
      if soundBusy(1) and pSound1 = what then
        exit
      end if
      set the volume of sound 1 to 200
      puppetSound(1, "walk")
      pSound1 = what
    #boat:
      if soundBusy(1) and pSound1 = what then
        exit
      end if
      set the volume of sound 1 to 175
      puppetSound(1, "boat")
      pSound1 = what
  end case
end

on sfx_play1stop me
  if soundBusy(1) then
    puppetSound(1, 0)
  end if
end

on sfx_play2 me, what
  case what of
    #push:
      set the volume of sound 2 to 255
      if soundBusy(2) and pSound2 = what then
        exit
      end if
      puppetSound(2, "push")
      pSound2 = what
    #bump:
      set the volume of sound 2 to 255
      if soundBusy(2) and pSound2 = what then
        exit
      end if
      puppetSound(2, "bump")
      pSound2 = what
    #DOOR:
      set the volume of sound 2 to 255
      if soundBusy(2) and pSound2 = what then
        exit
      end if
      puppetSound(2, "chimes")
      pSound2 = what
  end case
end

on sfx_play3 me, what
  set the volume of sound 3 to 255
  case what of
    #show:
      if soundBusy(3) and pSound3 = what then
        exit
      end if
      puppetSound(3, "message")
      pSound3 = what
    #secret:
      if soundBusy(3) and pSound3 = what then
        exit
      end if
      puppetSound(3, "discover")
      pSound3 = what
  end case
end

on correct me
  set the volume of sound 3 to 255
  puppetSound(3, "correct")
end

on incorrect me
  set the volume of sound 3 to 255
  puppetSound(3, "incorrect")
end

on click me
  set the volume of sound 3 to 255
  puppetSound(3, "click")
end

on win me
  set the volume of sound 3 to 255
  puppetSound(3, "win")
end

on lose me
  set the volume of sound 3 to 255
  puppetSound(3, "lose")
end

on checkTheme me
  if not soundBusy(4) then
    beginTheme(me)
  end if
end

on beginTheme me
  if doTheme = 1 then
    themeMain(me)
  end if
end

on startTheme me
  doTheme = 1
  beginTheme(me)
end

on stopTheme me
  doTheme = 0
  puppetSound(4, 0)
  numTimesMain = 0
end

on themeMain me
  numTimesMain = numTimesMain + 1
  if numTimesMain > 2 then
    i = random(2)
    if i = 1 then
      themeChangeOne(me)
    else
      themeChangeTwo(me)
    end if
  else
    set the volume of sound 4 to 200
    puppetSound(4, "theme.main")
  end if
end

on themeChangeOne me
  numTimesMain = 0
  set the volume of sound 4 to 200
  puppetSound(4, "theme.change.1")
end

on themeChangeTwo me
  numTimesMain = 0
  set the volume of sound 4 to 200
  puppetSound(4, "theme.change.2")
end

on someCuePassed me, theCue
  case 1 of
    theCue = "theme.main":
      i = random(3)
      case 1 of
        i = 1:
          themeMain(me)
        i = 2:
          themeChangeOne(me)
        i = 3:
          themeChangeTwo(me)
      end case
    theCue = "theme.change.1":
      themeMain(me)
    theCue = "theme.change.2":
      themeMain(me)
  end case
end

on maxVolumes me
  set the volume of sound 1 to 255
  set the volume of sound 2 to 255
  set the volume of sound 3 to 255
  set the volume of sound 4 to 255
end
