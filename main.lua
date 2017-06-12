-- Totally Not Animal Crossing
-- A mobile fishing game heavily-inspired by the fishing 
-- mechanics present in the Animal Crossing series.
-- Created by David San Antonio and Sebastian Coraccio 
-- A Primary Key game

-- Set up the composer
local composer = require('composer')
 
-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)
 
-- Seed the random number generator
math.randomseed(os.time())

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Create tables
-- TODO: Delete this line eventually
-------------------------------------
-- db.delete() -- TESTING ONLY
-------------------------------------
db.createTables()

-- Close the database
local function onSystemEvent( event )
  if ( event.type == "applicationExit" ) then
    db.closeDb()
  end
end
Runtime:addEventListener("system", onSystemEvent)

-- Go to the game
-- TODO: Eventually this should go to the main menu, going to game for now
composer.gotoScene('scenes.game')