global gSoundManager

on prepareFrame
  enterNewRoom()
end

on exitFrame
  gSoundManager.checkTheme()
end
