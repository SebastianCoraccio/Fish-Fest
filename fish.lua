----------------------------------------------------------------------------------------------------
-- fish.lua -- TNAC --
-- 
-- Fishing
--
-- David San Antonio
----------------------------------------------------------------------------------------------------
-- Require imports

-- Object to return to call from other scripts
local R = {}

-- Table to hold all fish
local fishTable = {}

-- Function to remove the fish
local function removeFish(time, fish)
  local function remove()
    table.remove(fishTable, table.indexOf(fishTable, fish))
    display.remove(fish)
  end
  timer.performWithDelay(time + 200, remove)
end
R.removeFish = removeFish

-- Fish spawn loop
local function spawnFish()
  -- Get random location
  local randX = 0
  if (math.random(0,1) == 1) then randX = display.contentWidth + 100 else randX = -100 end
  local randY = math.random(50, display.contentCenterY + 400)

  -- Create the fish, send to the back
  local fish = display.newCircle( randX, randY, 40 )
  fish:setFillColor(.17,.41,1, 0.70)
  -- fish:toBack()

  -- Insert into fish table to detect keep track of the fish
  table.insert(fishTable, fish)

  -- Start moving fish across screen
  -- TODO: For time, instead of random, will be different for each fish
  local randTime = math.random(5000,15000)
  if (fish.x == -100) then
    transition.to(fish, {x=display.contentWidth + 100, y=math.random(50, display.contentCenterY + 400),
      time=randTime, transition=easing.outQuad, onComplete=removeFish(randTime, fish)})
  else
    transition.to(fish, {x=-100, y=math.random(50, display.contentCenterY + 400),
      time=randTime, transition=easing.outQuad, onComplete=removeFish(randTime, fish)})
  end
end
R.spawnFish = spawnFish

return R