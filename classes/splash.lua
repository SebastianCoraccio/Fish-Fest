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

  local sheet_splash = graphics.newImageSheet("images/effects/splash.png", sheetOptions)

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

  splash.isActive = true
  splash.anim = display.newSprite(sheet_splash, sequence_splash)
  splash.anim.x = params.x
  splash.anim.y = params.y - 5
  physics.addBody(splash.anim, "dynamic", {filter = {groupIndex=-1}})
  splash.anim.myName = "splash"
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