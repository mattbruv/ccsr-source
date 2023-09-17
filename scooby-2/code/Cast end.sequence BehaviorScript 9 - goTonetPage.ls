on mouseUp
  if isShocked() then
    thisURL = ".."
    gotoNetPage(thisURL)
  end if
end

on mouseEnter
  cursor(280)
end

on mouseLeave
  cursor(0)
end
