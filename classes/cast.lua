-- Cast
-- Functions for physics and mechanics of casting and the bobber

-- Object to return to call from other scripts
local R = {}

-- Constants for speed of throw
local SPEED_MAXIMUM = 1200
local SPEED_MINIMUM = 100

-- Local boolean to keep track off if the user start to cast or not
local startedCast = false

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
    transition.to( bobber, { time=800, x=display.contentCenterX, y=display.contentCenterY + 500, 
      transition=easing.outQuad, xScale=1, yScale=1, onComplete=caught() } )
  end
end
R.catch = catch

-- Counter function to use for the casting speed
local counter = SPEED_MAXIMUM
local function count()
  counter = counter - 100
end

-- Function to do the cast
local function doSwipe( event )
  if (bobber.canBeSwiped == false) then return end
  if ( event.phase == "began" ) then
    display.getCurrentStage():setFocus( event.target )
    handle = timer.performWithDelay(50, count, 0)
  elseif ( event.phase == "moved" ) then
    if ( bobber.canBeSwiped == false ) then 
      return
    end
    -- Caculate deltaX and deltaY
    local deltaX = event.x - event.xStart
    local deltaY = event.y - event.yStart

    -- Stated cast
    startedCast = true

    -- Reset the counter
    counter = SPEED_MAXIMUM

    -- Calculate normal
    normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
  elseif ( event.phase == "ended" or event.phase == "cancelled" ) and (startedCast == true) then
  -- Stop the user from swiping after a delay, delay to stop it from being called immediately
    timer.performWithDelay(500, noSwipe)

    -- Cancel the timer for the speed
    timer.cancel(handle)
    speed = counter > 0 and counter or SPEED_MINIMUM -- Set the speed
    counter = SPEED_MAXIMUM -- Reset the counter

    -- Function to simulate arc of bobber
    local function scaleUp()
      local function scaleDown()
        transition.to(bobber, {time=1100, xScale=.8, yScale=.8})
      end
      transition.to(bobber, {time=600, xScale=1.6, yScale=1.6, onComplete=scaleDown})
    end

    -- Send bobber towards location with speed
    if (normDeltaX == nil or normDeltaY == nil) then
      startedCast = false
    else
      bobber:setLinearVelocity(normDeltaX  * speed, normDeltaY  * speed)
      scaleUp()
      startedCast = false
    end

    display.getCurrentStage():setFocus( nil )
  end
end
R.doSwipe = doSwipe

return R