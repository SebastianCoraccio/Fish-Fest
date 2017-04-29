-- Totally Not Animal Crossing
-- A mobile fishing game heavily-inspired by the fishing 
-- mechanics present in the Animal Crossing series.
-- Created by David San Antonio and Sebastian Coraccio 
-- A Primary Key game


-- Set up the composer
local composer = require( 'composer' )
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )

-- Go to the game
-- TODO: Eventually this should go to the main menu, going to game for now
composer.gotoScene( 'scenes.game' )