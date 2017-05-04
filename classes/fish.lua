-- Fish
-- Fish have two modes, seeking and pursing. 
-- When seeking they will move randomly to new locations and look for a bobber
-- If a bobber is within their line of site they will switch to pursing.
-- When the fish is pursuing it will hit the bobber, and eventually bite

local physics = require('physics')

local _Fish = {}

-- Fish = { MAX_BOBS = 5 }
-- Fish.__index = Fish

-- Creates a new fish at location (x,y), inside a bounded area 
-- defined by two vertex (minX, minY), (maxX, maxY)
function _Fish.create(maxX, maxY, minX, minY)
  local fish = {}
  fish.mode = "SEEKING"
  
  -- Max and Min define bounding area fish can move within
  fish.maxX, fish.maxY = maxX, maxY
  fish.minX, fish.minY = minX, minY

  -- Pick a random location for the fish to start as well as a rotation
  fish.x = math.random(minX, maxX)
  fish.y = math.random(minY, maxY)
  fish.dir = math.random(0, 360)

  -- Define a scale for the fish which will appropriately scale the fish components
  fish.scale = 0.6

  -- Create fish components
  -- TODO: Decide if scaling is what we want, or 4-5 predefined polygons for each fish size
  local fishPolygon = { -37,15 , -51,-38 , -41,-77 , 13,-99 , 43,-77 , 50,-37 , 39,18 , -1, 100 }
  local lineOfSight = { 225,-225 , 75,0 , -75,0 , -225,-225 , -150,-300 , 150,-300 }

  fish.anim = display.newImage("images/fish/silhouette.png", 0, 0)
  fish.anim.myName = "fish"
  -- Line of sight - los
  fish.los = display.newPolygon(0, 0, lineOfSight)
  fish.los.myName = 'los'
  fish.los.alpha = 0
  
  -- Move shapes to their new locations
  transition.to(fish.anim, {x=fish.x, y=fish.y, time=0})
  transition.to(fish.los, {x=fish.x, y=fish.y, time=0})
  transition.to(fish.anim, {rotation = fish.dir, time=0})
  transition.to(fish.los, {rotation = fish.dir, time=0})
  
  -- Create physics bodies
  physics.addBody(fish.anim, "dynamic", {shape=fff, isSensor=true})
  physics.addBody(fish.los, "dynamic", {shape=lineOfSight, isSenor=true})
  fish.anim.isSensor = true
  fish.los.isSensor = true

  -- Updates what the fix will do now based on its state
  function fish:update()
    if fish.mode == "SEEKING" then
      fish.anim:setFillColor(1,1,1)
      wait = math.random(0, 10) * 500 
      print(wait)
      timer.performWithDelay(wait, fish.changeLocation(), -1)
    end
    
  end

  -- Rotates the fish towards the given x,y location
  function fish:rotateTo(x, y)
    fish.dir = (math.atan2(fish.y - y, fish.x - x) * (180/math.pi)) - 90

    -- Rotate towards new position
    transition.to(fish.anim, {rotation = fish.dir % 360, time=1000})
    transition.to(fish.los, {rotation = fish.dir % 360, time=1000})
  end

  -- Moves the fish to the given x,y location
  function fish:moveTo(x, y)
    local dist = math.sqrt((x - fish.x)^2 + (y - fish.y)^2 )

    transition.to(fish.anim, {x=x, y=y, time=20*dist, transition=easing.outQuad})
    fish.x, fish.y = x, y
    transition.to(fish.los, {x=x, y=y, time=20*dist, transition=easing.outQuad}) 
  end

  -- Picks a random location in its bounding area
  function fish:changeLocation()
    local newX = fish.x + math.random(-100, 100)
    local newY = fish.y + math.random(-400, 400)

    -- Check new x and y are in the bounding area
    if newX > fish.maxX then
      newX = fish.maxX
    elseif newX < minX then
      newX = fish.minX
    end

    if newY > fish.maxY then
      newY = fish.maxY
    elseif newY < minY then
      newY = fish.minY
    end
    
    -- Rotate and move to new position
    fish:rotateTo(newX, newY)
    fish:moveTo(newX, newY)
    
  end

  -- To String method, returns string with x and y coordinate.
  function fish:tostring()
    return "Fish Location: (" .. fish.x .. ", " .. fish.y .. ")"
  end

  -- Collsion method
  function fish.los:collision(event)
    -- Check the other body that collided
    if event.other.myName == "bobber" then
      bobber = event.other
      if bobber.isActive then
        fish.anim:setFillColor(0,1,0)
        fish.mode = "PURSUING"
        transition.cancel(fish.anim)
        timer.performWithDelay(1000, fish:rotateTo(bobber.x, bobber.y))
      end
    end

  end
  fish.los:addEventListener('collision')

  return fish
end

return _Fish