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
        vibrate INT NOT NULL,
        sound INT NOT NULL,
        music INT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS Stats
      (
        level INT NOT NULL,
        exp INT NOT NULL
      );
    ]]
  end

  function Db:update(insertString)
    print(insertString)
    db:exec(insertString)
  end

  function Db:getRows(tableName)
    local ret = {}
    local counter = 1
    for row in db:nrows("SELECT * FROM " .. tableName) do
      ret[counter] = row
      counter = counter + 1
    end
    return ret
  end

  function Db:print()
    print("FishCaught")
    for row in db:nrows("SELECT * FROM FishCaught ORDER BY fid") do
      local str = ""
      for k, v in pairs(row) do
        str = str .. ("  " .. k .. ": " .. v)
      end
      print(str)
    end

    print("Flags")
    for row in db:nrows("SELECT * FROM Flags") do
      for k, v in pairs(row) do
        print(" " .. k .. ": " .. v)
      end
    end

    print("Stats")
    for row in db:nrows("SELECT * FROM Stats") do
      for k, v in pairs(row) do
        print(" " .. k .. ": " .. v)
      end
    end
  end

  -- Update DB when a fish is caught
  function Db:caughtFish(fid, weight, value)
    -- Check if that fish has already been caught before
    local fishCaught = Db:getRows("FishCaught")
    local fishInfo = require("data.fishInfo")
    local updated = false
    for i = 1, #fishCaught do
      -- Update row
      if (fishCaught[i].fid == fid) then
        local insert =
          [[UPDATE FishCaught SET numberCaught=]] ..
          fishCaught[i].numberCaught + 1 ..
            [[, largestCaught=]] .. math.max(fishCaught[i].largestCaught, weight) .. [[ WHERE fid=]] .. fid .. [[;]]
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

    local newExp = Db:getRows("Stats")[1].exp + value
    Db:update([[UPDATE Stats SET exp=]] .. newExp .. [[;]])

    Db:print()
  end

  function Db:updateLevel(level, overflowExp)
    local statement = [[UPDATE Stats SET level=]] .. level .. [[,exp=]] .. overflowExp .. [[;]]
    Db:update(statement)
  end

  -- Delete everything
  -- Should only be used in testing
  function Db:delete()
    db:exec [[
      DELETE FROM FishCaught;
      DELETE FROM Flags;
      INSERT INTO Flags VALUES (0, 0, 0);
      INSERT INTO Stats VALUES (1, 0);
    ]]
  end

  -- Delete everything in DB and redo it
  function Db:restart()
    db:exec [[
      DROP TABLE FishCaught;
      DROP TABLE Flags;
      DROP TABLE Stats;
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
        db:exec([[ALTER TABLE FishCaught ADD COLUMN ]] .. fishCaughtCols[i] .. [[ INT DEFAULT 0;]])
      end
    end

    if (#Db:getRows("Flags") == 0) then
      db:exec [[INSERT INTO Flags VALUES (0, 0, 0);]]
    end

    if (#Db:getRows("Stats") == 0) then
      db:exec [[INSERT INTO Stats VALUES (1, 0);]]
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
