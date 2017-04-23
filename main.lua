----------------------------------------------------------------------------------------------------
-- main.lua -- TNAC --
-- 
-- Sets up the composers
--
-- David San Antonio
----------------------------------------------------------------------------------------------------
-- Set up the composer
local composer = require( "composer" )
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )

-- Go to the game
-- TODO: Eventually this should go to the main menu, going to game for now
composer.gotoScene( "game" )