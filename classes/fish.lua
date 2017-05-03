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
      wait = math.random(0, 3000)
      timer.performWithDelay(wait, fish.change_location(), 0)
    end
    fish.anim:setFillColor(1,1,1)
    fish.los:setFillColor(1,1,1)
  end

  -- Picks a random location in its bounding area
  function fish:change_location()
    local oldX = fish.x
    local oldY = fish.y
    fish.x = fish.x + math.random(-300, 300)
    fish.y = fish.y + math.random(-300, 300)

    -- Check new x and y are in the bounding area
    if fish.x > fish.maxX then
      fish.x = fish.maxX
    elseif fish.x < minX then
      fish.x = fish.minX
    end

    if fish.y > fish.maxY then
      fish.y = fish.maxY
    elseif fish.y < minY then
      fish.y = fish.minY
    end
    -- Calculate the distance between the old loc and new loc
    -- Used to make fish move at a constant rate 
    -- regardless of distance it needs to move
    -- TODO: Actually make that work.
    local dist = math.sqrt((fish.x - oldX)^2 + (fish.y - oldY)^2 )
    fish.dir = (math.atan2(fish.y - oldY, fish.x - oldX) * (180/math.pi)) + 90
    
    -- Rotate towards new position
    transition.to(fish.anim, {rotation = fish.dir % 360, time=1000})
    transition.to(fish.los, {rotation = fish.dir % 360, time=1000})

    -- Move to new position
    transition.to(fish.anim, {x=fish.x, y=fish.y, time=20*dist, transition=easing.outQuad})
    transition.to(fish.los, {x=fish.x, y=fish.y, time=20*dist, transition=easing.outQuad})    
  end

  -- To String method, returns string with x and y coordinate.
  function fish:tostring()
    return "Fish Location: (" .. fish.x .. ", " .. fish.y .. ")"
  end

  -- Collsion method
  function fish.los:collision(event)
    -- Check the other body that collided
    if event.other.myName == "fish" then
      fish.anim:setFillColor(1,1,1)
    elseif event.other.myName == "los" then
      fish.anim:setFillColor(1,1,1)
    else
      print(event.other.isActive)
      if (event.other.isActive) then 
        fish.anim:setFillColor(0,1,0) 
      end
    end

  end
  fish.los:addEventListener('collision')

  return fish
end

return _Fish