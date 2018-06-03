-- Splash
-- A simple splash animation
-- Destroys self after animation has ended

local _Splash = {}

function _Splash.create(params) 
  local splash = {}

  local sheetOptions = 
  {
    width = 110,
    height = 75,
    numFrames = 6
  }

  local sheet_splash = graphics.newImageSheet("assets/effects/splash.png", sheetOptions)

  local sequence_splash = {
    {
      name = "splash",
      start = 1,
      count = 6,
      time = 550,
      loopCount = 1,
      loopDirection = "forward"
    }
  }

  
  splash.anim = display.newSprite(sheet_splash, sequence_splash)
  splash.anim.isActive = true
  splash.anim.x = params.x
  splash.anim.y = params.y
  splash.anim.myName = "splash"
  
  function splash.anim:preCollision(event)
    if event.other.myName == "bobber" then
      event.contact.isEnabled = false
    end
  end
  splash.anim:addEventListener("preCollision")

  if(params.collide == true) then
    physics.addBody(splash.anim, "dynamic", {filter = {groupIndex=-1}})
  end
  
  splash.anim:play()
  function splash:destroy()
    display.remove(splash.anim)
  end

  function spriteListener(event)
    local thisSprite = event.target

    if(event.phase == "ended") then
      splash:destroy()
    end
  end

  splash.anim:addEventListener("sprite", spriteListener)

  return splash
end

return _Splash