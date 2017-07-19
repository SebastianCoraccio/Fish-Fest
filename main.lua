-- Totally Not Animal Crossing
-- A mobile fishing game heavily-inspired by the fishing 
-- mechanics present in the Animal Crossing series.
-- Created by David San Antonio and Sebastian Coraccio 
-- A Primary Key game

-- Set up the composer
local composer = require('composer')

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Function that gets called each second to check if any active baits need to be removed
local function checkBaits()
  local baits = db:getRows("BaitUsages")
  -- Check if it still active
  -- get table of current date and time
  local t = os.date('*t')
  -- Get current time
  local currentTime = os.time(t)

  -- Check current time against time in db
  for i=1, #baits do
    -- Bait is expired
    if (baits[i].endTime <= tostring(currentTime)) then
      db:update("DELETE FROM BaitUsages WHERE location='" .. baits[i].location .. "';")
    end
  end
end
 
-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)
 
-- Seed the random number generator
math.randomseed(os.time())

-- Create tables
-- TODO: Delete this line eventually
-------------------------------------
-- db.restart() -- TESTING ONLY
-- db.delete() -- TESTING ONLY
-------------------------------------
-- Check if DB is different
db:createTables()
db:checkDb()

-- Tutorial reset
-- db:update("UPDATE StoreItems SET currentRodUpgrade = 0;")
-- db:update("UPDATE Flags SET watchedTutorial = 0;")

db:print()

-- Check if there is a bait in a loop every second
timer.performWithDelay(1000, checkBaits, 0)

-- Close the database
local function onSystemEvent( event )
  if ( event.type == "applicationExit" ) then
    db.closeDb()
  end
end
Runtime:addEventListener("system", onSystemEvent)

-- Set background color
display.setDefault("background", 1, 1, 1)

-- Go to the game
-- TODO: Eventually this should go to the main menu, going to game for now
composer.gotoScene('scenes.game', {params = {location='river'}})
-- composer.gotoScene('scenes.title', {params={}})
-- composer.gotoScene('scenes.store')