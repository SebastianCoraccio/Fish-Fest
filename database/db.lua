-- db
-- Creation of the database

local _DB = {}

function _DB.create()
  local Db = {}

  local sqlite3 = require("sqlite3")
  local path = system.pathForFile("database.db", system.DocumentsDirectory)
  local db = sqlite3.open(path)

  -- IF SCHEMA CHANGES MAKE SURE TO CHANGE THESE VARIABLES
  -- ALSO CHANGE TYPE TO CHANGE IT TO IN FUNCTION CHANGEDB
  local fishCaughtCols = {"fid", "largestCaught", "numberCaught"}

  -- Function to create the tables if they don't already exist
  -- IF SCHEMA CHANGES MAKE SURE TO CHANGE VARIABLES ABOVE
  -- ALSO CHANGE TYPE TO CHANGE IT TO IN FUNCTION CHANGEDB
  function Db:createTables()
    db:exec[[
      CREATE TABLE IF NOT EXISTS FishCaught
      (
        fid INT NOT NULL,
        largestCaught FLOAT NOT NULL,
        numberCaught INT NOT NULL,
        PRIMARY KEY (fid)
      );

      CREATE TABLE IF NOT EXISTS Flags
      (
        watchedTutorial INT NOT NULL,
        vibration INT NOT NULL,
        soundEffects INT NOT NULL,
        music INT NOT NULL
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
    for row in db:nrows("SELECT * FROM FishCaught ORDER BY fid") do
      local str = ""
      for k, v in pairs(row) do
        str = str .. ("  " .. k .. ": " .. v)
      end
      print(str)
    end

    -- Flags
    print("Flags")
    for row in db:nrows("SELECT * FROM Flags") do
      for k, v in pairs(row) do
        print(" " .. k .. ": " .. v)
      end
    end
  end

  -- Update DB when a fish is caught
  function Db:caughtFish(fid, weight)
    -- Check if that fish has already been caught before
    local fishCaught = Db:getRows("FishCaught")
    local fishInfo = require("data.fishInfo")

    -- Set weights
    -- local one = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
    -- local two = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
    -- local three = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
    -- local weight = math.round(((one + two + three) / 3.0) * 100) * 0.01

    local updated = false
    for i=1, #fishCaught do
      -- Update row
      if (fishCaught[i].fid == fid) then
        local insert = [[UPDATE FishCaught SET numberCaught=]] .. fishCaught[i].numberCaught + 1 .. 
          [[, largestCaught=]] .. math.max(fishCaught[i].largestCaught, weight) .. [[ WHERE fid=]] .. 
          fid .. [[;]]
        Db:update(insert)
        updated = true
        break
      end
    end

    if (updated == false) then
      -- Insert new row
      local insert = [[INSERT INTO FishCaught VALUES (]] .. fid .. [[, ]] .. weight .. [[, ]] .. 1 .. [[);]]
      Db:update(insert)
    end

    Db:print()
  end

  -- Delete everything
  -- Should only be used in testing
  function Db:delete()
    db:exec[[
      DELETE FROM FishCaught;
      DELETE FROM Flags;
      INSERT INTO Flags VALUES (0, 1, 1, 1);
    ]]
  end

  -- Delete everything in DB and redo it
  function Db:restart()
    db:exec[[
      DROP TABLE FishCaught;
      DROP TABLE Flags;
    ]]
    Db:createTables()
    -- Db:delete()
  end

  function Db:checkDb()
    -- Check if FishCaught table has changed
    for row in db:nrows("SELECT * FROM FishCaught") do
      for k, v in pairs(row) do
        table.remove(fishCaughtCols, table.indexOf(fishCaughtCols, k))
      end
    end
    if (#fishCaughtCols > 0) and (#Db:getRows("FishCaught") > 0) then
      for i = 1, #fishCaughtCols do
        print("Add to FishCaught: " .. fishCaughtCols[i])
        db:exec([[ALTER TABLE FishCaught ADD COLUMN ]] ..  fishCaughtCols[i] .. [[ INT DEFAULT 0;]])
      end
    end

    -- Prime Flags table
    if (#Db:getRows("Flags") == 0) then
      db:exec[[INSERT INTO Flags VALUES (0, 1, 1, 1);]]
    end
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