global gSoundManager

on exitFrame
  checkTheme(gSoundManager)
  go(the frame)
end
