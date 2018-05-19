-- ripple
-- A simple ripple animation
-- Destroys self after animation has ended

local _Ripple = {}

function _Ripple.create(params) 
  local ripple = {}

  local sheetOptions = 
  {
    width = 100,
    height = 75,
    numFrames = 6
  }

  local sheetRipple = graphics.newImageSheet("assets/effects/ripple.png", sheetOptions)

  local sequenceRipple = {
    {
      name = "ripple",
      start = 1,
      count = 6,
      time = 650,
      loopCount = 1,
      loopDirection = "forward"
    }
  }

  
  ripple.anim = display.newSprite(sheetRipple, sequenceRipple)
  ripple.anim:scale(1.5, 1.5)
  ripple.anim.isActive = true
  ripple.anim.x = params.x + 5
  ripple.anim.y = params.y
  ripple.anim.myName = "ripple"
  
  ripple.anim:play()
  function ripple:destroy()
    display.remove(ripple.anim)
  end

  function spriteListener(event)
    local thisSprite = event.target

    if(event.phase == "ended") then
      ripple:destroy()
    end
  end

  ripple.anim:addEventListener("sprite", spriteListener)

  return ripple
end

return _Ripple