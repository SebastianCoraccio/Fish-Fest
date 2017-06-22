-- db
-- Creation of the database

local _DB = {}

function _DB.create()
  local Db = {}

  local sqlite3 = require("sqlite3")
  local path = system.pathForFile("database.db", system.DocumentsDirectory)
  local db = sqlite3.open(path)

  -- Function to create the tables if they don't already exist
  function Db:createTables()
    db:exec[[
      CREATE TABLE IF NOT EXISTS FishCaught
      (
        fid INT NOT NULL,
        largestCaught FLOAT NOT NULL,
        numberCaught INT NOT NULL,
        PRIMARY KEY (fid)
      );

      CREATE TABLE IF NOT EXISTS BaitUsages
      (
        location VARCHAR(64) NOT NULL,
        baitType VARCHAR(64) NOT NULL,
        startTime VARCHAR(64) NOT NULL,
        endTime VARCHAR(64) NOT NULL,
        PRIMARY KEY (location)
      );

      CREATE TABLE IF NOT EXISTS StoreItems
      (
        currentRodUpgrade INT NOT NULL,
        chumCount INT NOT NULL,
        cherryCount INT NOT NULL,
        coins INT NOT NULL
      );
    ]]
  end

  -- Insert into Db
  function Db:update(insertString)
    print(insertString)
    db:exec(insertString)
  end

  -- Return all the rows of a certain table
  function Db:getRows(tableName)
    local ret = {}
    local counter = 1
    for row in db:nrows("SELECT * FROM " .. tableName) do
      ret[counter] = row
      counter = counter + 1
    end
    return ret
  end

  -- Print the Db
  function Db:print()
    -- FishCaught
    print("FishCaught")
    for row in db:nrows("SELECT * FROM FishCaught") do
      print(row.fid .. ",\t" .. row.largestCaught .. ",\t" .. row.numberCaught)
    end

    -- BaitUsages
    print("BaitUsages")
    for row in db:nrows("SELECT * FROM BaitUsages") do
      print(row.location .. ",\t" .. row.baitType .. ",\t" .. row.startTime .. ",\t" .. row.endTime)
    end

    -- StoreItems
    print("StoreItems")
    for row in db:nrows("SELECT * FROM StoreItems") do
      print(row.currentRodUpgrade .. ",\t" .. row.chumCount .. ",\t" .. row.cherryCount .. ",\t" .. row.coins)
    end
  end

  function Db:caughtFish(fid)
    -- Check if that fish has already been caught before
    local fishCaught = Db:getRows("FishCaught")
    local fishInfo = require("data.fishInfo")

    local updated = false
    for i=1, #fishCaught do
      -- Update row
      if (fishCaught[i].fid == fid) then
        -- TODO: Use actually gaussian weight insetad of 69.69
        local insert = [[UPDATE FishCaught SET numberCaught=]] .. fishCaught[i].numberCaught + 1 .. 
          [[, largestCaught=]] .. math.max(fishCaught[i].largestCaught, 69.69) .. [[ WHERE fid=]] .. 
          fid .. [[;]]
        Db:update(insert)
        updated = true
        break
      end
    end

    if (updated == false) then
      -- Insert new row
      local insert = [[INSERT INTO FishCaught VALUES (]] .. fid .. [[, ]] .. 69.69 .. [[, ]] .. 1 .. [[);]]
      Db:update(insert)
    end

    -- Get current coin total
    local currentCoins = Db:getRows("StoreItems")[1].coins

    -- Add coins to users total
    for i=1, #fishInfo do
      if (fishInfo[i].fid == fid) then
        local insert = [[UPDATE StoreItems SET coins=]] .. currentCoins + fishInfo[i].value .. [[;]]
        Db:update(insert)
      end
    end

    Db:print()
  end

  -- Delete everything and reset store items
  -- Should only be used in testing
  function Db:delete()
    db:exec[[
      DELETE FROM FishCaught;
      DELETE FROM BaitUsages;
      DELETE FROM StoreItems;
      INSERT INTO StoreItems VALUES (0, 0, 0, 0);
    ]]
  end

  -- Close the DB at the end of the game
  function Db:closeDb()
    if (db and db:isopen()) then
      db:close()
    end
  end

  return Db
end

return _DB