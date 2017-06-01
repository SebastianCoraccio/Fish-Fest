-- Fish
-- Fish have two modes, seeking and pursing. 
-- When seeking they will move randomly to new locations and look for a bobber
-- If a bobber is within their line of site they will switch to pursing.
-- When the fish is pursuing it will hit the bobber, and eventually bite

local utils = require('utils')
local physics = require('physics')
local fishInfo = require('locations.fishInfo')
local newSplash = require('classes.splash').create
local newRipple = require('classes.ripple').create
local _Fish = {}

-- Fish = { MAX_BOBS = 5 }
-- Fish.__index = Fish

-- Creates a new fish at location (x,y), inside a bounded area 
-- defined by two vertex (minX, minY), (maxX, maxY)
function _Fish.create(params)

  local fish = {}
  fish.mode = "SPAWNING"

  timer.performWithDelay(1000, function() fish.mode = "SEEKING" end)
  local fishScales = {.6,.8,1,1.2}

  fish.isBiting = false
  fish.moveTimer = nil
  fish.biteTimer = nil
  fish.tapTimers = {}

  -- Fish ID
  fish.fid = params.fid
  
  -- Import info about fish
  for i = 1, #fishInfo do
    if (fish.fid == fishInfo[i].fid) then
      fish.biteTime = fishInfo[i].biteTime
      fish.sizeGroup = fishInfo[i].sizeGroup
      fish.minSize = fishInfo[i].minSize
      fish.maxSize = fishInfo[i].maxSize
      break
    end
  end

  -- Max and Min define bounding area fish can move within
  fish.maxX, fish.maxY = params.maxX, params.maxY
  fish.minX, fish.minY = params.minX, params.minY

  -- Pick a random location for the fish to start as well as a rotation
  local fishX = math.random(fish.minX, fish.maxX)
  local fishY = math.random(fish.minY, fish.maxY)
  fish.dir = math.random(0, 360)

  -- DEBUGGING
  -- Fish spawns at display center and rotation to 0 
  -- local fishX = display.contentCenterX
  -- local fishY = display.contentCenterY
  -- fish.dir = 0 

  -- Define a scale for the fish which will appropriately scale the fish components
  fish.scale = 0.6

  -- Create fish components
  -- TODO: Decide if scaling is what we want, or 4-5 predefined polygons for each fish size
  local fishPolygon = { -37,15 , -51,-38 , -41,-77 , 13,-99 , 43,-77 , 50,-37 , 39,18 , -1, 100 }
  local lineOfSight = { 225,-225 , 75,0 , -75,0 , -225,-225 , -150,-300 , 150,-300 }

  fish.anim = display.newImage(params.group, "images/fish/silhouette.png", 0, 0)
  fish.anim.myName = "fish"
  fish.anim.alpha = 0
--   if (type(fish.sizeGroup) == "number") then
--     fish.anim:scale(fishScales[fish.sizeGroup], fishScales[fish.sizeGroup])
--   end
  -- Line of sight - los
  fish.los = display.newPolygon(params.group, 0, 0, lineOfSight)
  fish.los.myName = 'los'
  fish.los.alpha = 0
  
  -- Move shapes to their new locations
  transition.to(fish.anim, {x=fishX, y=fishY, time=0})
  transition.to(fish.los, {x=fishX, y=fishY, time=0})
  transition.to(fish.anim, {rotation = fish.dir, time=0})
  transition.to(fish.los, {rotation = fish.dir, time=0})
  
  -- Create physics bodies
  physics.addBody(fish.anim, "dynamic", {shape=fff, isSensor=true, filter = {groupIndex=-2}})
  physics.addBody(fish.los, "dynamic", {shape=lineOfSight, isSenor=true, filter = {groupIndex=-2}})
  fish.anim.isSensor = true
  fish.los.isSensor = true

  transition.to(fish.anim, {alpha = .7, time = 1000})
  
  -- Updates what the fix will do now based on its state
  function fish:update()
    if fish.mode == "SEEKING" then
      fish.anim:setFillColor(1,1,1)
      wait = math.random(2, 5) * 1000 
      fish.moveTimer = timer.performWithDelay(wait, fish.changeLocation, 1)
    end  
  end

  -- Rotates the fish towards the given x,y location
  function fish:rotateTo(params)
    -- TODO: Use utils function
    fish.dir = math.atan2(fish.anim.y - params.y, fish.anim.x - params.x) * (180/math.pi) - 90
    -- Rotate towards new position
    transition.to(fish.anim, {rotation = fish.dir, time=1000})
    transition.to(fish.los, {rotation = fish.dir, time=1000})
  end

  -- Moves the fish to the given x,y location
  function fish:moveTo(params)
    if params.speed == nil then
      params.speed = 20
    end

    local dist = utils.dist(fish.anim.x, fish.anim.y, params.x, params.y)

    transition.to(fish.anim, {x=params.x, 
                              y=params.y, 
                              time=params.speed*dist, 
                              alpha=params.alpha,
                              transition=easing.outQuad,
                              onComplete=params.onComplete})

    fish.x, fish.y = params.x, params.y

    transition.to(fish.los, {x=params.x, 
                             y=params.y, 
                             time=params.speed*dist, 
                             alpha=params.alpha,
                             transition=easing.outQuad}) 
  end


  -- Fish moves to the point, creates a ripple, then returns to original spot
  function fish:tap(params)

    -- Save the original point the fish is at
    local oldX = fish.anim.x
    local oldY = fish.anim.y

    -- Move to the point and create a ripple
    fish:moveTo({x=params.x, y=params.y, 
                 onComplete=function()
                   newRipple({x=params.bx, y=params.by}) 
                   -- Move back to orginal position
                    fish:moveTo({x=oldX, y=oldY})
                end})

    
  end

  -- Picks a random location in its bounding area
  function fish:changeLocation()
    local newX = fish.anim.x + math.random(-100, 100)
    local newY = fish.anim.y + math.random(-400, 400)

    -- Check new x and y are in the bounding area
    if newX > fish.maxX then
      newX = fish.maxX
    elseif newX < fish.minX then
      newX = fish.minX
    end

    if newY > fish.maxY then
      newY = fish.maxY
    elseif newY < fish.minY then
      newY = fish.minY
    end
    
    -- Rotate and move to new position
    fish:rotateTo({x=newX, y=newY})
    fish:moveTo({x=newX, y=newY})
  end

  -- -- Fish darts away from the given x and y position
  -- function fish:scare(params)

  --   fish.mode = "SCARED"

  --   -- Picks a location in the other direction of the given x and y
  --   local newX = fish.anim.x + math.random(-100, 100)
  --   local newY = fish.anim.y + math.random(-400, 400)
    
  --   -- Check new x and y are in the bounding area
  --   if newX > fish.maxX then
  --     newX = fish.maxX
  --   elseif newX < fish.minX then
  --     newX = fish.minX
  --   end

  --   if newY > fish.maxY then
  --     newY = fish.maxY
  --   elseif newY < fish.minY then
  --     newY = fish.minY
  --   end

  --   -- Rotate and move to new position
  --   fish:rotateTo({x=newX, y=newY, speed=8})
  --   fish:moveTo({x=newX, y=newY, 
  --                speed=8, 
  --                onComplete=function()
  --                  fish.mode = "SEEKING"
  --                end})
  -- end

  -- Destructor for the fish
  -- Removes the display objects
  function fish:destroy()
    display.remove(fish.anim)
    display.remove(fish.los)
	end

  -- Fish finds a new location and fades out
  -- Calls destroy
  function fish:scatter()
    -- Pick a new location 
    -- It can be out of bound because the fish is being destroyed
    local newX = fish.anim.x + math.random(-100, 100)
    local newY = fish.anim.y + math.random(-400, 400)

    -- Rotate and move to new position
    -- Alpha drops to zero as it moves
    fish:rotateTo({x=newX, y=newY})
    fish:moveTo({x=newX, 
                 y=newY, alpha = 0, 
                 onComplete = function() 
                   fish.mode = "DELETE"
                 end,
                 speed = 5})
  end

  -- Collsion method
  function fish.los:collision(event)
    -- Check the other body that collided
    if event.other.myName == "bobber" or event.other.myName == "splash" then
      bobber = event.other
      if bobber.isActive and fish.mode == "SEEKING" then
        fish.mode = "PURSUING"
        if fish.moveTimer ~= nil then
          timer.cancel(fish.moveTimer)
        end
        transition.cancel(fish.anim)
        fish:rotateTo({x=bobber.x, y=bobber.y})

        local x = bobber.x
        local y = bobber.y

        -- Get the point at the bobbers edge, and the point the fish will move back and forth between
        local bobberEdge = utils.getPointBetween(bobber.x, bobber.y, fish.anim.x, fish.anim.y, 135)
        local lookingPoint = utils.getPointBetween(bobber.x, bobber.y, fish.anim.x, fish.anim.y, 300)

        fish:moveTo({x=lookingPoint.x, y=lookingPoint.y})

        local numTaps = math.random(0,4)

        -- The delay increases with each tap to make the multiple taps
        -- happen at the correct intervals
        local delay = 1000
        for i=1, numTaps do
          t = timer.performWithDelay(delay, function() 
            fish:tap({x=bobberEdge.x, y=bobberEdge.y, bx=x, by=y}) 
          end)  

          --  Insert it into the table so it can be canceled if 
          -- fish isreeled in too quickly
          table.insert( fish.tapTimers, t)

          delay = delay + 2500
        end     
        
        t = timer.performWithDelay(delay, function() 
              fish:moveTo({x=bobberEdge.x, y=bobberEdge.y, 
                           onComplete=function()
                             newSplash({x=x, y=y, collide = false}) 
                             fish.isBiting=true

                             -- TODO: Add timestamp for determining fish to catch
                             -- in the case 2 or more bite at once
                             fish.biteTimer = timer.performWithDelay(fish.biteTime, function()
                               fish.isBiting = false
                               fish:scatter()
                           end) 
              end})
            end)

        table.insert(fish.tapTimers, t)

      end
    end

  end
  fish.los:addEventListener('collision')

  -- Collsion method
  -- TODO: Fix this 
  -- function fish.anim:collision(event)
  --   -- Check the other body that collided
  --   if event.other.myName == "splash" then
  --     if event.other.isActive and fish.mode == "SEEKING" then
  --       fish:scare({x=event.other.x, y=event.other.y})
  --     end
  --   end
  -- end
  -- fish.anim:addEventListener('collision')

  -- Checks if a fish is caught
  function fish:checkCaught(event)
    -- Fish is biting, timer has been started
    -- Fish is caught
    if fish.isBiting then
      timer.cancel(fish.biteTimer)
      return 2
    -- Fish has not bit the lure yet but is pursuing
    -- Fish runs away
    elseif fish.mode == "PURSUING" then
      for i=#fish.tapTimers, 1, -1 do
        timer.cancel(fish.tapTimers[i])
      end
      transition.cancel(fish.anim)
      transition.cancel(fish.los)
      return 1
    -- Fish timer has scattered and need to be deleted
    elseif fish.mode == "DELETE" then
      return 1
    -- Fish has nothing to do with the lure
    else
      return 0
    end
  end
  
  return fish
end

return _Fish