----------------------------------------------------------------------------------------------------
-- main.lua -- TNAC --
-- 
-- Casting code. Will probably need to be moved. Just implementing in main for now.
--
-- David San Antonio
----------------------------------------------------------------------------------------------------
-- Bobber image
local bobber = display.newCircle( display.contentCenterX, display.contentCenterY + 400, 25 )

bobber.canBeSwiped = true

-- Function to be called when the player reeled in the bobber
local function caught()
  -- bobber:removeEventListener("touch", catch)
  bobber:addEventListener("touch", doSwipe)
  bobber.canBeSwiped = true
end

-- Function to to the catching
local function catch( event )
  if (event.phase == "ended" or event.phase == "cancelled") then
    transition.to( bobber, { x=display.contentCenterX, y=display.contentCenterY, 
      transition=easing.outQuad } )
  end
end

-- Function to be called when the player cast to bobber
local function casted()
  -- bobber:removeEventListener("touch", doSwipe)
  -- bobber:addEventListener("touch", catch)
end

-- Function to do the cast
local function doSwipe( event )
  -- Set focus on the bobber
  if ( event.phase == "began" ) then
    display.getCurrentStage():setFocus( event.target )
  elseif ( event.phase == "moved" ) then
    if ( bobber.canBeSwiped == false ) then
      return
    end
  elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
    bobber.canBeSwiped = false

    -- Make sure the bobber cant be put off screen
    xLocation = event.x
    yLocation = event.y
    if (event.x <= 50) then
      xLocation = 50
    elseif (event.x >= display.contentWidth - 50) then
      xLocation = display.contentWidth - 50
    end

    if (event.y >= display.contentCenterY + 400) then
      -- Don't cast the bobber
      yLocation = display.contentCenterY + 400
      xLocation = display.contentCenterX
    elseif (event.y <= 50) then
      yLocation = 50
    end
    -- Move the bobber
    transition.to( bobber, { x=xLocation, y=yLocation, transition=easing.outQuad, 
      onComplete=casted() } )
  end
end

-- Add listener on bobber
bobber:addEventListener( "touch", doSwipe )