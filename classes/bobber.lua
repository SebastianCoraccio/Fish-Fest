local newDB = require("database.db").create
local db = newDB()
local newSplash = require("classes.splash").create
local bobberHit = audio.loadSound("audio/bobber_hit.wav")

local _Bobber = {}

function _Bobber.create(x, y, group)
  local bobber = {}
  local casting = false
  local counter = 0
  bobber.anim = display.newImage(group, "assets/bobber.png", x, y)
  bobber.anim.myName = 'bobber'
  bobber.anim.isActive = false
  bobber.anim.isCatchable = false
  physics.addBody(bobber.anim, {density = 1.0, friction = 0.3, bounce = 0.2, radius = 37.5})

  function bobber:destroy()
    physics.removeBody(bobber.anim)
    bobber.anim:removeSelf()
  end

  -- Switches the boolean of canBeCast
  -- Used for showing the modal
  function bobber:setCast()
    bobber.canBeCast = not bobber.canBeCast
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
    if (bobber.casting) then
      return
    end
    -- if (event.phase == "ended" or event.phase == "cancelled") and (bobber.canBeCast == false) then
    -- Catch event activates, which the game scene catches and checks if fish were caught
    local catchEvent = {name = "catchEvent", target = "scene"}
    bobber.anim:dispatchEvent(catchEvent) -- Catch event
    bobber.anim.isActive = false
    bobber.anim.isCatchable = false
    bobber.anim:setLinearVelocity(0, 0) -- stop the bobber
    transition.to(
      bobber.anim,
      {
        time = 800,
        x = display.contentWidth / 2,
        y = display.contentHeight - 200,
        transition = easing.outQuad,
        xScale = 1,
        yScale = 1,
        rotation = 0,
        onComplete = bobber.caught()
      }
    ) -- BRING HIM HOME
  end

  function bobber:cast(event)
    if (bobber.canBeCast == false) then
      return
    end
    bobber.casting = true
    -- Function to simulate arc of bobber
    local function scaleUp()
      local function scaleDown()
        transition.to(
          bobber.anim,
          {
            time = 1100,
            xScale = 0.5,
            yScale = 0.5,
            onComplete = function()
              if (db:getRows("Flags")[1].sound == 1) then
                audio.play(bobberHit)
              end
              newSplash({x = bobber.anim.x, y = bobber.anim.y, collide=true})

              bobber.anim.isActive = true
              bobber.anim.isCatchable = true
              bobber.anim:setLinearVelocity(0, 0)
              bobber.casting = false
            end
          }
        )
      end
      transition.to(bobber.anim, {time = speed, xScale = 1.6, yScale = 1.6, onComplete = scaleDown})
    end

    scaleUp()
  end

  function bobber:bringBack()
    bobber.anim.isActive = false -- bobber isn't active
    bobber.anim.isCatchable = false -- bobber isn't catchable
    bobber.anim:setLinearVelocity(0, 0) -- stop the bobber
    transition.to(
      bobber.anim,
      {
        time = 800,
        x = display.contentWidth / 2,
        y = display.contentHeight - 200,
        transition = easing.outQuad,
        rotation = 0,
        xScale = 1,
        yScale = 1,
        onComplete = bobber.caught()
      }
    ) -- BRING HIM HOME
  end

  function moveBobber()
    counter = counter + 1
    if (bobber.anim.isActive and bobber.anim.isCatchable and counter % 2 == 0) then
      bobber.anim.y = bobber.anim.y + math.sin(counter / 10) / 1.2
      bobber.anim.rotation = bobber.anim.rotation + math.sin(counter / 10) / 1.2
    end
  end

  Runtime:addEventListener("enterFrame", moveBobber)

  return bobber
end

return _Bobber
