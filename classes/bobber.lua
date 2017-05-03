-- Bobber
-- Bobber will be cast and caught from here

-- Physics
local physics = require('physics')

-- Bobber object
local _Bobber = {}

-- Constants for speed of throw
local SPEED_MAXIMUM = 1200
local SPEED_MINIMUM = 100

-- Local boolean to keep track off if the user start to cast or not
local startedCast = false

-- Counter for the speed calculation
local counter = SPEED_MAXIMUM

-- Create a bobber at location (x,y)
function _Bobber.create(x, y)
    local bobber = {}

    -- Set the location
    bobber.x, bobber.y = x, y

    -- Bobber can be swiped initial
    bobber.canBeCast = true

    -- Set the image
    bobber.anim = display.newCircle(x, y, 25)
    bobber.anim.myName = "bobber"

    -- Physics body
    physics.addBody(bobber.anim, "dynamic")
    bobber.anim.linearDamping = 1

    -- Function to be called when the player reeled in the bobber
    function bobber:caught()
        bobber.canBeCast = true
    end

    -- Function to stop the swiping
    function bobber:noCast()
        bobber.canBeCast = false
    end

    -- Function to to the catching
    function bobber:catch(event)
        -- if (event.phase == "ended" or event.phase == "cancelled") and (bobber.canBeCast == false) then
        if bobber.canBeCast == false then
            bobber.anim:setLinearVelocity(0, 0)
            transition.to(bobber.anim, {time=800, x=display.contentCenterX, y=display.contentCenterY + 500, 
            transition=easing.outQuad, xScale=1, yScale=1, onComplete=bobber.caught()})
        end
    end

    -- Counter function to use for the casting speed
    function bobber:count()
        counter = counter - 100
    end

    -- Function to do the cast
    function bobber:cast(event)
        print(event)
        if (bobber.canBeCast == false) then return end
        if (event.phase == "began") then
            display.getCurrentStage():setFocus(event.target)
            handle = timer.performWithDelay(50, bobber.count, 0)
        elseif (event.phase == "moved") then
            if (bobber.canBeCast == false) then 
            return
            end
            -- Caculate deltaX and deltaY
            local deltaX = event.x - event.xStart
            local deltaY = event.y - event.yStart

            -- Stated cast
            startedCast = true

            -- Calculate normal
            normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
            normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
        elseif (event.phase == "ended" or event.phase == "cancelled") and (startedCast == true) then
        -- Stop the user from swiping after a delay, delay to stop it from being called immediately
            timer.performWithDelay(500, bobber.noCast)

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
                bobber.anim:setLinearVelocity(normDeltaX  * speed, normDeltaY  * speed)
                scaleUp()
                startedCast = false
            end

            display.getCurrentStage():setFocus(nil)
        elseif (startedCast == false) then
            counter = SPEED_MAXIMUM
        end
    end

    function bobber.anim:touch(event)
        bobber:cast(event)
    end

    -- Add event listener for cast
    bobber.anim:addEventListener('touch')

    return bobber
end

return _Bobber
