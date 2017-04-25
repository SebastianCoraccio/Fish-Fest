----------------------------------------------------------------------------------------------------
-- cast.lua -- TNAC --
-- 
-- Casting
--
-- David San Antonio
----------------------------------------------------------------------------------------------------
-- Require imports
-- local catch = require( "catch" )

-- Object to return to call from other scripts
local R = {}

-- Function to be called when the player reeled in the bobber
local function caught()
  bobber.canBeSwiped = true
end
R.caught = caught

-- Function to to the catching
local function catch( event )
  if (event.phase == "ended" or event.phase == "cancelled") then
    transition.to( bobber, { x=display.contentCenterX, y=display.contentCenterY + 500, 
      transition=easing.outQuad, onComplete=caught() } )
  end
end
R.catch = catch

-- Function to do the cast
local function doSwipe( event )
  if (bobber.canBeSwiped == false) then
    catch(event)
  -- Set focus on the bobber
  elseif ( event.phase == "began" ) then
    display.getCurrentStage():setFocus( event.target )
  elseif ( event.phase == "moved" ) then
    if ( bobber.canBeSwiped == false ) then
      catch(event)
    end
  elseif (event.phase == "ended" or event.phase == "cancelled") and (bobber.canBeSwiped == true) then
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
    transition.to( bobber, { x=xLocation, y=yLocation, transition=easing.outQuad} )
  elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
    print("here")
    display.getCurrentStage():setFocus( nil )
  end
end
R.doSwipe = doSwipe

return R