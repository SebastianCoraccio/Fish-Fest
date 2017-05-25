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

    local max = fish[1].spawnChance
    -- Loop through all the fish
    for i = 1, #fish, 1 do
      if (chance <= max) then
        return fish[i]
      else
        max = max + fish[i].spawnChance
      end
    end

    return fish[#fish]
  end

  return location
end

return _Location