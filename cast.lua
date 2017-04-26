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

-- Function to stop the swiping
local function noSwipe()
  bobber.canBeSwiped = false
end
R.noSwipe = noSwipe

-- Function to to the catching
local function catch( event )
  if (event.phase == "ended" or event.phase == "cancelled") and (bobber.canBeSwiped == false) then
    bobber:setLinearVelocity( 0, 0 )
    transition.to( bobber, { x=display.contentCenterX, y=display.contentCenterY + 400, 
      transition=easing.outQuad, onComplete=caught() } )
  end
end
R.catch = catch

local counter = 0
local function count()
  counter = counter + 1
end

-- Function to do the cast
local function doSwipe( event )
  if (bobber.canBeSwiped == false) then return end
  if ( event.phase == "began" ) then
    display.getCurrentStage():setFocus( event.target )
    handle = timer.performWithDelay(10, count, 0)
  elseif ( event.phase == "moved" ) then
    if ( bobber.canBeSwiped == false ) then 
      return
    end
    -- Caculate deltaX and deltaY
    local deltaX = event.x - event.xStart
    local deltaY = event.y - event.yStart

    -- Calculate normal
    normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
  elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
  -- Stop the user from swiping after a delay, delay to stop it from being called immediately
    timer.performWithDelay(500, noSwipe)

    timer.cancel(handle)
    print(counter)
    counter = 0
    
    speed = 500

    -- Send bobber towards location with speed
    bobber:setLinearVelocity(normDeltaX  * speed, normDeltaY  * speed)

    display.getCurrentStage():setFocus( nil )
    print("FOCUS RELEASED")
  end
end
R.doSwipe = doSwipe

return R