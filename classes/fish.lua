-- Fish
-- Fish have two modes, seeking and pursing. 
-- When seeking they will move randomly to new locations and look for a bobber
-- If a bobber is within their line of site they will switch to pursing.
-- When the fish is pursuing it will hit the bobber, and eventually bite

Fish = { MAX_BOBS = 5 }
Fish.__index = Fish

-- Creates a new fish at location (x,y), inside a bounded area 
-- defined by two vertex (minX, minY), (maxX, maxY)
function Fish.create(x, y, maxX, maxY, minX, minY)
  local fish = setmetatable({}, Fish)
  fish.x, fish.y = x,y
  fish.maxX, fish.maxY = maxX, maxY
  fish.minX, fish.minY = minX, minY
  fish.mode = "SEEKING"
  fish.anim = display.newCircle( x, y, 40 )
  fish.anim:setFillColor(.17,.41,1, 0.70)

  -- Updates what the fix will do now based on its state
  function Fish:update()
    print("Update has been called.")
    if fish.mode == "SEEKING" then
      fish.change_location()
    end
  end

  -- Picks a random location in its bounding area
  function Fish:change_location()
    oldX = fish.x
    oldY = fish.y
    fish.x = fish.x + math.random(-250, 250)
    fish.y = fish.y + math.random(-250, 250)

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

    -- print(fish.tostring())

    -- Calculate the distance between the old loc and new loc
    -- Used to make fish move at a constant rate 
    -- regardless of distance it needs to move
    -- TODO: Actually make that work.
    dist = math.sqrt((fish.x - oldX)^2 + (fish.y - oldY)^2 )

    transition.to(fish.anim, {x=fish.x, y=fish.y, time=30*dist, transition=easing.outQuad})
  end

  -- To String method, returns string with x and y coordinate.
  function Fish:tostring()
    return "Fish Location: (" .. fish.x .. ", " .. fish.y .. ")"
  end

  return fish
end