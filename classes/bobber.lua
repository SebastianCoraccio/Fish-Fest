-- Bobber
-- Bobber will be cast and caught from here

-- Physics
local physics = require('physics')
local newSplash = require('classes.splash').create
-- Bobber object
local _Bobber = {}

-- Constants for speed of throw
-- local SPEED_MAXIMUM = 1300
-- local SPEED_MINIMUM = 100

-- Counter for the speed calculation
-- local counter = SPEED_MAXIMUM

-- Create a bobber at location (x,y)
function _Bobber.create(x, y)
    local bobber = {}

    -- Set the location
    bobber.x, bobber.y = x, y

    -- Bobber can be swiped initial
    bobber.canBeCast = true

    -- Set the bigger back circle to recieve touch events
    bobber.back = display.newCircle(x, y, 75)
    bobber.back:setFillColor(1,0.01)
    bobber.back:toFront()

    -- Set the image
    bobber.anim = display.newImage("images/bobber.png", x, y)
    bobber.anim.myName = "bobber"

    -- Power meter
    bobber.power = display.newRect(x, y - bobber.anim.height / 2, 50, 0)
    bobber.power:setFillColor(.5, .5, .5)
    bobber.power.anchorX = .5
    bobber.power.anchorY = 1

    -- If the cast was started
    bobber.startedCast = false

    -- If the bobber is active
    bobber.anim.isActive = false
    bobber.anim.isCatchable = false

    -- Physics body
    physics.addBody(bobber.anim, "dynamic", {filter = {groupIndex=-1}})
    bobber.anim.linearDamping = 1


    -- Get bobber x, y
    function bobber:getLocation()
        return bobber.x, bobber.y
    end

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
        if bobber.canBeCast == false and bobber.anim.isCatchable == true then

            -- Catch event activates, which the game scene catches and checks if fish were caught
            local catchEvent = {name="catchEvent", target="scene"}
            bobber.anim:dispatchEvent(catchEvent) -- Catch event
            bobber.anim.isActive = false -- bobber isn't active
            bobber.anim.isCatchable = false -- bobber isn't catchable
            bobber.anim:setLinearVelocity(0, 0) -- stop the bobber
            transition.to(bobber.anim, {time=800, x=display.contentCenterX, y=display.contentCenterY + 500, 
            transition=easing.outQuad, xScale=1, yScale=1, onComplete=bobber.caught()}) -- BRING HIM HOME
        end
    end

    -- Counter function to use for the casting speed
    -- function bobber:count()
    --     counter = counter - 100
    -- end

    -- Function to do the cast
    function bobber:cast(event)
        if (bobber.canBeCast == false) then return end
        if (event.phase == "began") then
            -- counter = SPEED_MAXIMUM
            display.getCurrentStage():setFocus(event.target)
            -- handle = timer.performWithDelay(80, bobber.count, 0)
        elseif (event.phase == "moved") then
            if (bobber.canBeCast == false) then 
            return
            end
            -- Caculate deltaX and deltaY
            local deltaX = event.x - event.xStart
            local deltaY = event.y - event.yStart

            -- Set power meter
            bobber.power.height = math.sqrt((deltaX)^2 + (deltaY)^2)
            if (bobber.power.height > 500) then
                bobber.power.height = 500
            end
            bobber.power.rotation = (math.atan2(deltaY, deltaX) * (180/math.pi) + 90) % 360

            -- Stated cast
            bobber.startedCast = true

            -- Calculate normal
            normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
            normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
        elseif (event.phase == "ended" or event.phase == "cancelled") and (bobber.startedCast == true) then
        -- Stop the user from swiping after a delay, delay to stop it from being called immediately
            timer.performWithDelay(500, bobber.noCast)

            -- Cancel the timer for the speed
            -- timer.cancel(handle)
            -- speed = counter > 0 and counter or SPEED_MINIMUM -- Set the speed
            speed = bobber.power.height * 2.8
            -- counter = SPEED_MAXIMUM -- Reset the counter    

            -- Function to simulate arc of bobber
            local function scaleUp()
                local function scaleDown()
                    transition.to(bobber.anim, {time=1100, xScale=.8, yScale=.8, 
                    onComplete=function()
                        newSplash({x=bobber.anim.x, y=bobber.anim.y})
                        bobber.anim.isActive = true
                        bobber.anim.isCatchable = true
                        bobber.anim:setLinearVelocity(0, 0)
                    end})
                end
                transition.to(bobber.anim, {time=speed, xScale=1.6, yScale=1.6, onComplete=scaleDown})
            end

            -- Send bobber towards location with speed
            if (normDeltaX == nil or normDeltaY == nil) then
                bobber.startedCast = false
            else
                bobber.anim:setLinearVelocity(normDeltaX  * speed, normDeltaY  * speed)
                bobber.power.height = 0 -- reset power meter
                scaleUp()
                bobber.startedCast = false
            end

            display.getCurrentStage():setFocus(nil)
        elseif (bobber.startedCast == false) then
            -- counter = SPEED_MAXIMUM
        end
    end

    -- Bobber.anim touch passes event to the cast function
    function bobber.back:touch(event)
        bobber:cast(event)
    end

    -- Add event listener for cast
    bobber.back:addEventListener('touch')

    return bobber
end

return _Bobber
