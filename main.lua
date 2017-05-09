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
require("database.db")

-- Load the DB
local sqlite3 = require("sqlite3")
local path = system.pathForFile("database.db", system.DocumentsDirectory)
local db = sqlite3.open(path)

-- Close the database
local function onSystemEvent( event )
    if ( event.type == "applicationExit" ) then
        if ( db and db:isopen() ) then
            db:close()
        end
    end
end
Runtime:addEventListener( "system", onSystemEvent )

-- Go to the game
-- TODO: Eventually this should go to the main menu, going to game for now
composer.gotoScene('scenes.game')