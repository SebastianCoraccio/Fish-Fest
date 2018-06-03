-- location
-- Returns a fish from a given location

local _Location = {}
-- Create a new location
function _Location.create(locationName)
  local location = {}

  -- Set up DB
  local newDB = require("database.db").create
  local db = newDB()

  -- Get fish information for that location
  local fish = require("data." .. locationName).fish

  -- Give a random fish
  function location:giveFish()
    -- Calculate chance
    local chance = math.random() + math.random(0, 99)

    local max = 0
    -- Loop through all the fish
    for i = 1, #fish, 1 do
      max = max + fish[i].spawnChance
      if (chance <= max) then
        local fish = fish[i]
        return fish
      end
    end

    return fish[#fish]
  end

  return location
end

return _Location