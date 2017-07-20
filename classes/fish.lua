-- Fish
-- Fish have two modes, seeking and pursing. 
-- When seeking they will move randomly to new locations and look for a bobber
-- If a bobber is within their line of site they will switch to pursing.
-- When the fish is pursuing it will hit the bobber, and eventually bite

local utils = require('utils')
local physics = require('physics')
local fishInfo = require('data.fishInfo')
local newSplash = require('classes.splash').create
local newRipple = require('classes.ripple').create
local _Fish = {}

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Fish = { MAX_BOBS = 5 }
-- Fish.__index = Fish

-- Creates a new fish at location (x,y), inside a bounded area 
-- defined by two vertex (minX, minY), (maxX, maxY)
function _Fish.create(params)

  local fishBite = audio.loadSound("audio/fish_bite.wav")  

  local fish = {}
  
  -- Start fish as spawning so it will ignore the bobber as it fades in
  fish.mode = "SPAWNING"
  timer.performWithDelay(1000, function() fish.mode = "SEEKING" end)
  
  
  fish.isBiting = false
  fish.moveTimer = nil
  fish.biteTimer = nil
  fish.tapTimers = {}

  -- Fish ID
  fish.fid = params.fid
  -- Import info about fish
  fish.biteTime = fishInfo[fish.fid].biteTime
  fish.sizeGroup = fishInfo[fish.fid].sizeGroup
  fish.minSize = fishInfo[fish.fid].minSize
  fish.maxSize = fishInfo[fish.fid].maxSize

  -- @DELETE
  local fishScale;
  if(fish.sizeGroup == 'tiny') then fishScale = .6
  elseif(fish.sizeGroup == 'small') then fishScale = .8
  elseif(fish.sizeGroup == 'large') then fishScale = 1.2
  elseif(fish.sizeGroup == 'tiger') then fishScale = 1.2
  else fishScale = 1 end
  
  -- Max and Min define bounding area fish can move within
  fish.maxX, fish.maxY = params.maxX, params.maxY
  fish.minX, fish.minY = params.minX, params.minY
  
--   local lineOfSight = { 225,-225 , 75,0 , -75,0 , -225,-225 , -150,-300 , 150,-300 }

  -- @DELETE  
  local lineOfSight = { 225*fishScale,-225*fishScale , 75*fishScale,0 , -75*fishScale,0 , -225*fishScale,-225*fishScale , -150*fishScale,-300*fishScale , 150*fishScale,-300*fishScale }
    
  local sheetOptions =
  {
    width = 66,
    height = 200,
    numFrames = 8
  }

  local sheetFishAnim = graphics.newImageSheet("images/fish/silhouette/medium.png", sheetOptions);

  local sequenceAnim = {
    {
      name = "stationary",
      start = 1,
      count = 8, 
      time = 1200,
      loopDirection = "forward"
    },
    {
      name = "moving",
      start = 1,
      count = 8, 
      time = 800,
      loopDirection = "forward"
    }
  }

  -- Generate start (x, y) position and rotation
  local startX = math.random(fish.minX, fish.maxX)
  local startY = math.random(fish.minY, fish.maxY)
  local startRotation = math.random(0, 360)
  
  fish.anim = display.newSprite(params.group, sheetFishAnim, sequenceAnim)
  fish.anim:scale(fishScale, fishScale) --@DELETE
  fish.anim.myName = "fish"
  fish.anim.alpha = 0
  fish.anim:setSequence("stationary")
  fish.anim:play()
  
  -- Create Fish Line of Sight (los) polygon
  fish.los = display.newPolygon(params.group, startX, startY, lineOfSight)
  fish.los.myName = 'los'
  fish.los.alpha = 0
  
  -- Move the fish and los to the correct location and rotation
  transition.to(fish.anim, {
    x=startX, 
    y=startY,
    rotation = startRotation,
    time = 0
  })
  
  transition.to(fish.los, {rotation = startRotation, time=0})

  -- Create physics bodies
  physics.addBody(fish.anim, "dynamic", {shape=fff, isSensor=true, filter = {groupIndex=-2}})
  physics.addBody(fish.los, "dynamic", {shape=lineOfSight, isSenor=true, filter = {groupIndex=-2}})
  fish.anim.isSensor = true
  fish.los.isSensor = true

  transition.to(fish.anim, {alpha = .4, time = 1000})
  
  -- Updates what the fix will do now based on its state
  function fish:update()
    if fish.mode == "SEEKING" then
      wait = math.random(3, 5) * 1000 
      fish.moveTimer = timer.performWithDelay(wait, fish.changeLocation, 1)
    end  
  end

  -- Rotates the fish towards the given x,y location
  function fish:rotateTo(params)
    local rotation = utils.rotationTo(params.x, params.y, fish.anim.x, fish.anim.y, fish.anim.rotation)
    -- Rotate towards new position
    transition.to(fish.anim, {rotation = rotation, time=1000})
    transition.to(fish.los, {rotation = rotation, time=1000})
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

    transition.to(fish.los, {x=params.x, 
                             y=params.y, 
                             time=params.speed*dist, 
                             alpha=params.alpha,
                             transition=easing.outQuad}) 
  end


  -- Fish moves to the point, creates a ripple, then returns to original spot
  -- Params
  -- bobberEdgeX, bobberEdgeY - Border of the bobber between the fish and bobber center 
  -- bobberCenterX, bobberCenterY - Center of bobber
  -- lpointX, lpointY - Point a distance away from the bobber, where the fish looks from
  function fish:tap(params)

    -- Move to the point and create a ripple
    fish:moveTo({x=params.bobberEdgeX, y=params.bobberEdgeY, 
                 onComplete=function()
                   newRipple({x=params.bobberCenterX, y=params.bobberCenterY}) 
                   -- Move back to orginal position
                --    fish:rotateTo({x=params.bobberEdgeX, y=params.bobberEdgeY})
                   fish:moveTo({x=params.lpointX, y=params.lpointY})
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
        local bobberEdge = utils.getPointBetween(bobber.x, bobber.y, fish.anim.x, fish.anim.y, 135 * fishScale) -- @DELETE
        local lookingPoint = utils.getPointBetween(bobber.x, bobber.y, fish.anim.x, fish.anim.y, 300)

        local numTaps = math.random(0,4)

        -- The delay increases with each tap to make the multiple taps
        -- happen at the correct intervals
        local delay = 1000
        for i=1, numTaps do
          t = timer.performWithDelay(delay, function() 
            fish:tap({bobberEdgeX=bobberEdge.x, bobberEdgeY=bobberEdge.y, 
                      bobberCenterX=x, bobberCenterY=y,
                      lpointX=lookingPoint.x, lpointY=lookingPoint.y}) 
          end)  

          --  Insert it into the table so it can be canceled if 
          -- fish isreeled in too quickly
          table.insert( fish.tapTimers, t)

          delay = delay + 2500
        end     
        
        t = timer.performWithDelay(delay, function() 
              fish:moveTo({x=bobberEdge.x, y=bobberEdge.y, 
                           onComplete=function()
                              if (db:getRows("Flags")[1].vibration == 1) then
                                system.vibrate()
                              end
                              if (db:getRows("Flags")[1].soundEffects == 1) then
                                audio.play(fishBite)
                              end
                              newSplash({x=x, y=y, collide = false}) 
                              fish.isBiting=true

                              -- TODO: Add timestamp for determining fish to catch
                              -- in the case 2 or more bite at once
                              local totalBiteTime = fish.biteTime + params.rod;

                              -- Add in extra time if in tutorial
                              if (db:getRows("Flags")[1].watchedTutorial == 0) then
                                totalBiteTime = totalBiteTime + 1000
                              end

                              -- Check if the bite times is negative. 
                              -- If it is then the player has no chance to catch this fish
                              -- Potentially add special sound or message 
                              -- to alert player to upgrade rod
                              if(totalBiteTime <= 0) then
                                fish.isBiting = false
                                fish:scatter()
                              else
                                 fish.biteTimer = timer.performWithDelay(totalBiteTime, function()
                                 fish.isBiting = false
                                 fish:scatter()
                               end)
                             end 
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