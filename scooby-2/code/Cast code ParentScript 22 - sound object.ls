property pMyState, pSoundList, pAmbientSound, pFadeList
global gSpriteTable, gGameMgr

on new me
  pMyState = 0
  pAmbientSound = "good loop"
  pFadeList = [:]
  me.mInit()
  return me
end

on mInit me
  me.pMyState = 1
  me.mSetVolume(1, 150)
end

on mRun me
end

on mSetMyState me, thisState
  me.pMyState = thisState
end

on mGetMyState me
  return me.gMyState
end

on mPlaySound me, thisSound, thisChannel
  puppetSound(thisChannel, thisSound)
end

on mMustPlaySound me, thisSound, thisChannel
  if soundBusy(thisChannel) then
    puppetSound(thisChannel, 0)
  end if
  puppetSound(thisChannel, thisSound)
end

on mStopSound me, thisChannel
  if soundBusy(thisChannel) then
    puppetSound(thisChannel, 0)
  end if
end

on mPlayAmbient me
  puppetSound(1, me.pAmbientSound)
end

on mStopAmbient me
  puppetSound(1, 0)
end

on mTrySound me, thisSound, thisChannel
  if soundBusy(thisChannel) then
    exit
  end if
  puppetSound(thisChannel, thisSound)
end

on mPlaySoundOnly me, thisSound, thisChannel
  repeat with i = 1 to 8
    if soundBusy(i) then
      puppetSound(i, 0)
    end if
  end repeat
  puppetSound(thisChannel, thisSound)
end

on mSoundDone me, thisChannel
  if soundBusy(thisChannel) then
    return 0
  end if
  return 1
end

on mStopAllSounds me
  me.pAmbientSound = EMPTY
  repeat with i = 1 to 8
    puppetSound(i, 0)
  end repeat
end

on mSetVolume me, thisChannel, thisValue
  if (thisValue <= 255) and (thisValue >= 0) then
    set the volume of sound thisChannel to thisValue
  end if
end

on mGetVolume me, thisChannel
  return the volume of sound thisChannel
end

on mFadeChannels me, firstChannel, thisLastChannel
  repeat with i = firstChannel to thisLastChannel
    me.mFadeChannel(i, 0)
  end repeat
end

on mFadeChannel me, thisChannel, inOrOut
  thisValue = getaProp(me.pFadeList, thisChannel)
  if not voidp(thisValue) then
    deleteProp(me.pFadeList, thisChannel)
  end if
  setaProp(me.pFadeList, thisChannel, inOrOut)
end

on mDoFade me
  if me.pFadeList <> [] then
    numChannels = me.pFadeList.count
    repeat while numChannels
      thisFade = me.pFadeList[numChannels]
      if thisFade then
        thisMult = 1.35000000000000009
      else
        thisMult = 0.90000000000000002
      end if
      thisChannel = getPropAt(me.pFadeList, numChannels)
      thisVolume = me.mGetVolume(thisChannel)
      if (thisVolume = 0) and thisFade then
        thisVolume = 5
      end if
      thisVolume = thisVolume * thisMult
      if not thisFade then
        if thisVolume <= 5 then
          thisVolume = 0
          deleteAt(me.pFadeList, numChannels)
        end if
      else
        if thisVolume >= 255 then
          thisVolume = 255
          deleteAt(me.pFadeList, numChannels)
        end if
      end if
      me.mSetVolume(thisChannel, thisVolume)
      numChannels = numChannels - 1
    end repeat
  end if
end

on mSetAmbient me, thisSound
  if me.pAmbientSound = thisSound then
    exit
  end if
  me.pAmbientSound = thisSound
  if thisSound = "null" then
    me.mStopAmbient()
  else
    me.mPlayAmbient()
  end if
end
