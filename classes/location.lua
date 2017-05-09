-- location
-- Returns a fish from a given location

local _Location = {}
-- Create a new location
function _Location.create(locationName)
  local location = {}

  -- Get fish information for that location
  local fish = require("locations." .. locationName).fish

  -- Give a random fish
  function location:giveFish()
    -- Calculate chance
    local chance = math.random() + math.random(0, 99)

    -- Loop through all the fish
    for i = 1, #fish, 1 do
      local max = 0
      -- Return the fish if we get to the last one
      if (i + 1 > #fish) then 
        return fish[i]
      else
        max = fish[i + 1].spawnChance
      end
      -- If the chance picked is within the range for that fish, return it
      if (fish[i].spawnChance < chance) and (chance < max) then
        return fish[i]
      end
    end
  end

  return location
end

return _Location