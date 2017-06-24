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
  
  -- Information about trash
  local trash = require("data.trash")

  local function giveTrash()
    return trash[math.random(1,3)]
  end

  -- Give a random fish
  function location:giveFish()
    -- Check for baits to increase chance
    local baitAddition = 0
    local baitUsages = db:getRows('baitUsages')
    local affectedFID = 0
    for i=1,#baitUsages do
      if (baitUsages[i].location == locationName) then
        local baits = require("data.baitInfo")
        local bait
        for j=1,#baits do
          if (baitUsages[i].baitType == baits[j].name) then
            bait = baits[j]
            affectedFID = baits[j].affectedFish
            break
          end
        end
        baitAddition = 5
        break
      end
    end

    -- Calculate chance
    local chance = math.random() + math.random(0, 99 + baitAddition)

    -- If chance is greater than 100, bait is used and want to return affected fish
    if (chance > 100) then
      for i=1,#fish, 1 do
        if (fish[i].fid == affectedFID) then
          print("Special fish: " .. fish[i].fid)
          return fish[i]
        end
      end
    end

    local max = 0
    -- Loop through all the fish
    for i = 1, #fish, 1 do
      max = max + fish[i].spawnChance
      if (chance <= max) then
        local fish = fish[i]
        if (fish.fid == 99) then
          return giveTrash()
        end
        return fish
      end
    end

    return fish[#fish]
  end

  return location
end

return _Location